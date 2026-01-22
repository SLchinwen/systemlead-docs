-- Archive DB DDL
-- Scope: Archive Invoice Governance PRD v1.0
-- Includes:
--   1) InvoiceArchiveHeader (single-file aggregated invoice header)
--   2) ArchiveJobLog (ETL batch log)
-- Notes:
--   - Keep Archive DB read-only for app users (write only by ETL service account).
--   - ProofUri should be relative path; do NOT store pre-signed URLs.

/* ==========================================================
   A) SQL Server (2019+ recommended)
   ========================================================== */

-- 0) Schema
IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'archive')
    EXEC('CREATE SCHEMA archive');
GO

-- 1) Archive job log
IF OBJECT_ID('archive.ArchiveJobLog', 'U') IS NULL
BEGIN
    CREATE TABLE archive.ArchiveJobLog (
        JobLogId            BIGINT IDENTITY(1,1) NOT NULL,
        ArchiveBatchId      UNIQUEIDENTIFIER NOT NULL,
        JobName             NVARCHAR(100) NOT NULL,   -- e.g. 'ArchiveInvoiceETL'
        RunStartedAt        DATETIME2(3) NOT NULL,
        RunFinishedAt       DATETIME2(3) NULL,
        Status              NVARCHAR(20) NOT NULL,    -- 'Running'|'Succeeded'|'Failed'
        SourceTimeMin       DATETIME2(3) NULL,        -- ETL scan window
        SourceTimeMax       DATETIME2(3) NULL,
        RowsExtracted       BIGINT NOT NULL CONSTRAINT DF_ArchiveJobLog_RowsExtracted DEFAULT(0),
        RowsUpserted        BIGINT NOT NULL CONSTRAINT DF_ArchiveJobLog_RowsUpserted DEFAULT(0),
        RowsRejected        BIGINT NOT NULL CONSTRAINT DF_ArchiveJobLog_RowsRejected DEFAULT(0),
        AmountTotal         DECIMAL(19,2) NOT NULL CONSTRAINT DF_ArchiveJobLog_AmountTotal DEFAULT(0),
        AllowanceTotal      DECIMAL(19,2) NOT NULL CONSTRAINT DF_ArchiveJobLog_AllowanceTotal DEFAULT(0),
        ErrorSummary        NVARCHAR(2000) NULL,
        CreatedAt           DATETIME2(3) NOT NULL CONSTRAINT DF_ArchiveJobLog_CreatedAt DEFAULT(SYSUTCDATETIME()),
        CONSTRAINT PK_ArchiveJobLog PRIMARY KEY CLUSTERED (JobLogId)
    );
END
GO

CREATE INDEX IX_ArchiveJobLog_BatchId ON archive.ArchiveJobLog(ArchiveBatchId);
GO

-- 2) Invoice archive header
IF OBJECT_ID('archive.InvoiceArchiveHeader', 'U') IS NULL
BEGIN
    CREATE TABLE archive.InvoiceArchiveHeader (
        -- A) Identity & keys
        SellerBan               CHAR(8) NOT NULL,                -- 賣方統編
        InvoiceNo               NVARCHAR(20) NOT NULL,           -- 發票號（含字軌+號碼）
        InvoiceYear             INT NOT NULL,                    -- 年度（建議以開立年）
        InvoicePeriod           CHAR(6) NULL,                    -- 選用：雙月期別 YYYYMM（起始月）
        InvoiceKey              AS (CONCAT(SellerBan, ':', InvoiceNo)) PERSISTED, -- 查找主鍵
        DataVersion             NVARCHAR(10) NOT NULL CONSTRAINT DF_InvArch_DataVersion DEFAULT('v1'),

        -- B) Datetimes
        InvoiceDateTime          DATETIME2(3) NOT NULL,          -- 開立時間
        VoidDateTime             DATETIME2(3) NULL,              -- 作廢時間
        LastAllowanceDateTime    DATETIME2(3) NULL,              -- 最後折讓時間
        UploadDateTime           DATETIME2(3) NULL,              -- 上傳/存證完成時間
        ArchiveBatchId           UNIQUEIDENTIFIER NOT NULL,      -- 彙總批次

        -- C) Amounts / tax
        TaxType                  TINYINT NOT NULL,               -- 1應稅 2零稅 3免稅 9混稅
        SalesAmount              DECIMAL(19,2) NOT NULL,
        ZeroTaxSalesAmount       DECIMAL(19,2) NOT NULL,
        FreeTaxSalesAmount       DECIMAL(19,2) NOT NULL,
        TaxAmount                DECIMAL(19,2) NOT NULL,
        TotalAmount              DECIMAL(19,2) NOT NULL,
        AllowanceTotalAmount     DECIMAL(19,2) NOT NULL CONSTRAINT DF_InvArch_AllowanceTotal DEFAULT(0),
        NetTotalAmount           AS (
                                    CASE
                                        WHEN InvoiceStatus = 'Voided' THEN CONVERT(DECIMAL(19,2), 0)
                                        ELSE (TotalAmount - AllowanceTotalAmount)
                                    END
                                  ) PERSISTED,

        -- D) Relations
        OrderNo                  NVARCHAR(64) NULL,              -- 選用：遮罩後訂單號（若要完全不留原值，可改為 NULL 一律）
        OrderNoHash              VARBINARY(32) NULL,             -- HMAC-SHA256
        BuyerBan                 CHAR(8) NULL,                   -- 買方統編（B2B）
        LastAllowanceNo          NVARCHAR(30) NULL,              -- 最後折讓單號
        AllowanceCount           INT NOT NULL CONSTRAINT DF_InvArch_AllowanceCount DEFAULT(0),

        -- E) Status
        InvoiceStatus            NVARCHAR(10) NOT NULL,          -- 'Issued'|'Voided'
        AllowanceStatus          NVARCHAR(10) NOT NULL,          -- 'None'|'Partial'|'Full'
        DocType                  NVARCHAR(10) NOT NULL CONSTRAINT DF_InvArch_DocType DEFAULT('Invoice'),
        IsUploaded               BIT NOT NULL CONSTRAINT DF_InvArch_IsUploaded DEFAULT(0),

        -- F) Proof & source
        ProofKey                 NVARCHAR(100) NULL,
        ProofUri                 NVARCHAR(400) NULL,             -- relative path
        SourceSystem             NVARCHAR(20) NULL,              -- 'API'|'Excel'|'FTP'|'ThirdParty'
        SourceRef                NVARCHAR(100) NULL,

        -- G) Audit fields
        CreatedAt                DATETIME2(3) NOT NULL CONSTRAINT DF_InvArch_CreatedAt DEFAULT(SYSUTCDATETIME()),
        UpdatedAt                DATETIME2(3) NOT NULL CONSTRAINT DF_InvArch_UpdatedAt DEFAULT(SYSUTCDATETIME()),

        CONSTRAINT PK_InvoiceArchiveHeader PRIMARY KEY CLUSTERED (SellerBan, InvoiceNo),
        CONSTRAINT CK_InvArch_TaxType CHECK (TaxType IN (1,2,3,9)),
        CONSTRAINT CK_InvArch_Status CHECK (InvoiceStatus IN ('Issued','Voided')),
        CONSTRAINT CK_InvArch_AllowanceStatus CHECK (AllowanceStatus IN ('None','Partial','Full')),
        CONSTRAINT CK_InvArch_AmountsNonNeg CHECK (
            SalesAmount >= 0 AND ZeroTaxSalesAmount >= 0 AND FreeTaxSalesAmount >= 0 AND
            TaxAmount >= 0 AND TotalAmount >= 0 AND AllowanceTotalAmount >= 0
        )
    );
END
GO

-- Helpful indexes
CREATE UNIQUE INDEX UX_InvArch_InvoiceKey ON archive.InvoiceArchiveHeader(InvoiceKey);
CREATE INDEX IX_InvArch_InvoiceDateTime ON archive.InvoiceArchiveHeader(InvoiceDateTime);
CREATE INDEX IX_InvArch_OrderNoHash ON archive.InvoiceArchiveHeader(OrderNoHash);
CREATE INDEX IX_InvArch_BuyerBan ON archive.InvoiceArchiveHeader(BuyerBan);
CREATE INDEX IX_InvArch_Status ON archive.InvoiceArchiveHeader(InvoiceStatus, AllowanceStatus, TaxType);
CREATE INDEX IX_InvArch_BatchId ON archive.InvoiceArchiveHeader(ArchiveBatchId);
GO

-- Trigger to maintain UpdatedAt on update (optional)
IF OBJECT_ID('archive.TR_InvArch_UpdatedAt', 'TR') IS NULL
BEGIN
    EXEC('CREATE TRIGGER archive.TR_InvArch_UpdatedAt ON archive.InvoiceArchiveHeader
          AFTER UPDATE AS
          BEGIN
              SET NOCOUNT ON;
              UPDATE t
              SET UpdatedAt = SYSUTCDATETIME()
              FROM archive.InvoiceArchiveHeader t
              INNER JOIN inserted i ON t.SellerBan = i.SellerBan AND t.InvoiceNo = i.InvoiceNo;
          END');
END
GO

/* ----------------------------------------------------------
   SQL Server partitioning (MONTHLY on InvoiceDateTime)

   Recommended when Archive DB grows large.
   This section provides:
     1) Partition function PF_InvArch_InvoiceDate_Monthly (RANGE RIGHT)
     2) Partition scheme   PS_InvArch_InvoiceDate_Monthly
     3) A "fresh install" create-table script that places the clustered index on the partition scheme
     4) A monthly maintenance procedure to add next month boundary

   IMPORTANT:
   - If you already created archive.InvoiceArchiveHeader earlier (non-partitioned), do NOT run the
     "fresh install" part directly. Use the "migration" steps below.
   - Adjust filegroups if you want partitions on multiple filegroups.

   ----------------------------------------------------------
   1) Partition function & scheme
   ---------------------------------------------------------- */

-- Choose a starting month boundary. Example: keep partitions from 2020-01 onward.
-- RANGE RIGHT means boundary value belongs to the RIGHT partition.
IF NOT EXISTS (SELECT 1 FROM sys.partition_functions WHERE name = 'PF_InvArch_InvoiceDate_Monthly')
BEGIN
    DECLARE @sql_pf NVARCHAR(MAX) = N'CREATE PARTITION FUNCTION PF_InvArch_InvoiceDate_Monthly (DATETIME2(3))
    AS RANGE RIGHT FOR VALUES (
        ''2020-02-01T00:00:00.000'',
        ''2020-03-01T00:00:00.000'',
        ''2020-04-01T00:00:00.000''
        -- ADD MORE BOUNDARIES HERE (monthly)
    );';
    EXEC(@sql_pf);
END
GO

-- Partition scheme (single filegroup by default)
IF NOT EXISTS (SELECT 1 FROM sys.partition_schemes WHERE name = 'PS_InvArch_InvoiceDate_Monthly')
BEGIN
    EXEC(N'CREATE PARTITION SCHEME PS_InvArch_InvoiceDate_Monthly
          AS PARTITION PF_InvArch_InvoiceDate_Monthly
          ALL TO ([PRIMARY]);');
END
GO

/* ----------------------------------------------------------
   2) FRESH INSTALL (create partitioned table)

   Use this only if archive.InvoiceArchiveHeader does NOT exist yet.
   It places the CLUSTERED PRIMARY KEY on the partition scheme using InvoiceDateTime.
   ---------------------------------------------------------- */

IF OBJECT_ID('archive.InvoiceArchiveHeader', 'U') IS NULL
BEGIN
    CREATE TABLE archive.InvoiceArchiveHeader (
        -- A) Identity & keys
        SellerBan               CHAR(8) NOT NULL,
        InvoiceNo               NVARCHAR(20) NOT NULL,
        InvoiceYear             INT NOT NULL,
        InvoicePeriod           CHAR(6) NULL,
        InvoiceKey              AS (CONCAT(SellerBan, ':', InvoiceNo)) PERSISTED,
        DataVersion             NVARCHAR(10) NOT NULL CONSTRAINT DF_InvArch_DataVersion DEFAULT('v1'),

        -- B) Datetimes
        InvoiceDateTime          DATETIME2(3) NOT NULL,
        VoidDateTime             DATETIME2(3) NULL,
        LastAllowanceDateTime    DATETIME2(3) NULL,
        UploadDateTime           DATETIME2(3) NULL,
        ArchiveBatchId           UNIQUEIDENTIFIER NOT NULL,

        -- C) Amounts / tax
        TaxType                  TINYINT NOT NULL,
        SalesAmount              DECIMAL(19,2) NOT NULL,
        ZeroTaxSalesAmount       DECIMAL(19,2) NOT NULL,
        FreeTaxSalesAmount       DECIMAL(19,2) NOT NULL,
        TaxAmount                DECIMAL(19,2) NOT NULL,
        TotalAmount              DECIMAL(19,2) NOT NULL,
        AllowanceTotalAmount     DECIMAL(19,2) NOT NULL CONSTRAINT DF_InvArch_AllowanceTotal DEFAULT(0),
        -- NOTE: Persisted computed columns can be used with partitioning; keep expression deterministic.
        NetTotalAmount           AS (
                                    CASE
                                        WHEN InvoiceStatus = 'Voided' THEN CONVERT(DECIMAL(19,2), 0)
                                        ELSE (TotalAmount - AllowanceTotalAmount)
                                    END
                                  ) PERSISTED,

        -- D) Relations
        OrderNo                  NVARCHAR(64) NULL,
        OrderNoHash              VARBINARY(32) NULL,
        BuyerBan                 CHAR(8) NULL,
        LastAllowanceNo          NVARCHAR(30) NULL,
        AllowanceCount           INT NOT NULL CONSTRAINT DF_InvArch_AllowanceCount DEFAULT(0),

        -- E) Status
        InvoiceStatus            NVARCHAR(10) NOT NULL,
        AllowanceStatus          NVARCHAR(10) NOT NULL,
        DocType                  NVARCHAR(10) NOT NULL CONSTRAINT DF_InvArch_DocType DEFAULT('Invoice'),
        IsUploaded               BIT NOT NULL CONSTRAINT DF_InvArch_IsUploaded DEFAULT(0),

        -- F) Proof & source
        ProofKey                 NVARCHAR(100) NULL,
        ProofUri                 NVARCHAR(400) NULL,
        SourceSystem             NVARCHAR(20) NULL,
        SourceRef                NVARCHAR(100) NULL,

        -- G) Audit fields
        CreatedAt                DATETIME2(3) NOT NULL CONSTRAINT DF_InvArch_CreatedAt DEFAULT(SYSUTCDATETIME()),
        UpdatedAt                DATETIME2(3) NOT NULL CONSTRAINT DF_InvArch_UpdatedAt DEFAULT(SYSUTCDATETIME()),

        CONSTRAINT CK_InvArch_TaxType CHECK (TaxType IN (1,2,3,9)),
        CONSTRAINT CK_InvArch_Status CHECK (InvoiceStatus IN ('Issued','Voided')),
        CONSTRAINT CK_InvArch_AllowanceStatus CHECK (AllowanceStatus IN ('None','Partial','Full')),
        CONSTRAINT CK_InvArch_AmountsNonNeg CHECK (
            SalesAmount >= 0 AND ZeroTaxSalesAmount >= 0 AND FreeTaxSalesAmount >= 0 AND
            TaxAmount >= 0 AND TotalAmount >= 0 AND AllowanceTotalAmount >= 0
        )
    ) ON PS_InvArch_InvoiceDate_Monthly(InvoiceDateTime);

    -- Clustered PK must be aligned with partitioning key for best manageability.
    -- We include InvoiceDateTime as the 3rd key to align the clustered index with partitioning.
    ALTER TABLE archive.InvoiceArchiveHeader
    ADD CONSTRAINT PK_InvoiceArchiveHeader
    PRIMARY KEY CLUSTERED (SellerBan, InvoiceNo, InvoiceDateTime)
    ON PS_InvArch_InvoiceDate_Monthly(InvoiceDateTime);

    -- Secondary indexes
    CREATE UNIQUE INDEX UX_InvArch_InvoiceKey ON archive.InvoiceArchiveHeader(InvoiceKey)
      ON PS_InvArch_InvoiceDate_Monthly(InvoiceDateTime);

    CREATE INDEX IX_InvArch_InvoiceDateTime ON archive.InvoiceArchiveHeader(InvoiceDateTime)
      ON PS_InvArch_InvoiceDate_Monthly(InvoiceDateTime);

    CREATE INDEX IX_InvArch_OrderNoHash ON archive.InvoiceArchiveHeader(OrderNoHash)
      ON PS_InvArch_InvoiceDate_Monthly(InvoiceDateTime);

    CREATE INDEX IX_InvArch_BuyerBan ON archive.InvoiceArchiveHeader(BuyerBan)
      ON PS_InvArch_InvoiceDate_Monthly(InvoiceDateTime);

    CREATE INDEX IX_InvArch_Status ON archive.InvoiceArchiveHeader(InvoiceStatus, AllowanceStatus, TaxType)
      ON PS_InvArch_InvoiceDate_Monthly(InvoiceDateTime);

    CREATE INDEX IX_InvArch_BatchId ON archive.InvoiceArchiveHeader(ArchiveBatchId)
      ON PS_InvArch_InvoiceDate_Monthly(InvoiceDateTime);
END
GO

/* ----------------------------------------------------------
   3) MIGRATION (if table already exists non-partitioned)

   High-level steps (safe, repeatable):
     a) Create new partitioned table: archive.InvoiceArchiveHeader_p
     b) Create same constraints/indexes aligned to partition scheme
     c) Backfill: INSERT INTO ... SELECT ... FROM old table
     d) Swap names in a transaction (or use synonym)
     e) Recreate triggers

   NOTE:
   - SQL Server cannot "convert" an existing heap/clustered index table into partitioned
     without rebuilding the clustered index onto the partition scheme (which effectively is a rebuild).
   - If data volume is huge, consider doing backfill in batches by month.
   ---------------------------------------------------------- */

/* ----------------------------------------------------------
   4) Monthly maintenance: add next month boundary

   Run monthly (or schedule) to ensure next month partition exists.
   ---------------------------------------------------------- */

IF OBJECT_ID('archive.usp_InvArch_AddNextMonthBoundary', 'P') IS NULL
    EXEC('CREATE PROCEDURE archive.usp_InvArch_AddNextMonthBoundary AS BEGIN SET NOCOUNT ON; END');
GO

ALTER PROCEDURE archive.usp_InvArch_AddNextMonthBoundary
    @NextMonthStart DATETIME2(3) = NULL  -- if NULL, auto-calc next month boundary from current date
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @boundary DATETIME2(3);

    IF @NextMonthStart IS NULL
    BEGIN
        -- Compute first day of next month in UTC to match SYSUTCDATETIME() usage
        DECLARE @utcNow DATETIME2(3) = SYSUTCDATETIME();
        DECLARE @thisMonthStart DATETIME2(3) = DATEFROMPARTS(YEAR(@utcNow), MONTH(@utcNow), 1);
        SET @boundary = DATEADD(MONTH, 1, @thisMonthStart);
    END
    ELSE
    BEGIN
        SET @boundary = @NextMonthStart;
    END

    -- Check if boundary already exists
    IF EXISTS (
        SELECT 1
        FROM sys.partition_range_values prv
        JOIN sys.partition_functions pf ON pf.function_id = prv.function_id
        WHERE pf.name = 'PF_InvArch_InvoiceDate_Monthly'
          AND CONVERT(DATETIME2(3), prv.value) = @boundary
    )
    BEGIN
        RETURN;
    END

    DECLARE @sql NVARCHAR(MAX) = N'ALTER PARTITION SCHEME PS_InvArch_InvoiceDate_Monthly NEXT USED [PRIMARY];
                                  ALTER PARTITION FUNCTION PF_InvArch_InvoiceDate_Monthly() SPLIT RANGE (''' +
                                  CONVERT(NVARCHAR(30), @boundary, 126) + N''');';
    EXEC(@sql);
END
GO



/* ==========================================================
   B) PostgreSQL (13+ recommended)
   ========================================================== */

-- 0) Schema
CREATE SCHEMA IF NOT EXISTS archive;

-- 1) Archive job log
CREATE TABLE IF NOT EXISTS archive.archive_job_log (
  job_log_id          BIGSERIAL PRIMARY KEY,
  archive_batch_id    UUID NOT NULL,
  job_name            VARCHAR(100) NOT NULL,
  run_started_at      TIMESTAMPTZ NOT NULL,
  run_finished_at     TIMESTAMPTZ NULL,
  status              VARCHAR(20) NOT NULL,
  source_time_min     TIMESTAMPTZ NULL,
  source_time_max     TIMESTAMPTZ NULL,
  rows_extracted      BIGINT NOT NULL DEFAULT 0,
  rows_upserted       BIGINT NOT NULL DEFAULT 0,
  rows_rejected       BIGINT NOT NULL DEFAULT 0,
  amount_total        NUMERIC(19,2) NOT NULL DEFAULT 0,
  allowance_total     NUMERIC(19,2) NOT NULL DEFAULT 0,
  error_summary       VARCHAR(2000) NULL,
  created_at          TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS ix_archive_job_log_batch_id
  ON archive.archive_job_log(archive_batch_id);

-- 2) Invoice archive header
-- Recommended: partition by range on invoice_datetime (monthly)
CREATE TABLE IF NOT EXISTS archive.invoice_archive_header (
  seller_ban              CHAR(8) NOT NULL,
  invoice_no              VARCHAR(20) NOT NULL,
  invoice_year            INT NOT NULL,
  invoice_period          CHAR(6) NULL,
  invoice_key             TEXT GENERATED ALWAYS AS (seller_ban || ':' || invoice_no) STORED,
  data_version            VARCHAR(10) NOT NULL DEFAULT 'v1',

  invoice_datetime         TIMESTAMPTZ NOT NULL,
  void_datetime            TIMESTAMPTZ NULL,
  last_allowance_datetime  TIMESTAMPTZ NULL,
  upload_datetime          TIMESTAMPTZ NULL,
  archive_batch_id         UUID NOT NULL,

  tax_type                 SMALLINT NOT NULL,
  sales_amount             NUMERIC(19,2) NOT NULL,
  zero_tax_sales_amount    NUMERIC(19,2) NOT NULL,
  free_tax_sales_amount    NUMERIC(19,2) NOT NULL,
  tax_amount               NUMERIC(19,2) NOT NULL,
  total_amount             NUMERIC(19,2) NOT NULL,
  allowance_total_amount   NUMERIC(19,2) NOT NULL DEFAULT 0,
  net_total_amount         NUMERIC(19,2) GENERATED ALWAYS AS (
                              CASE
                                WHEN invoice_status = 'Voided' THEN 0
                                ELSE (total_amount - allowance_total_amount)
                              END
                            ) STORED,

  order_no                 VARCHAR(64) NULL,
  order_no_hash            BYTEA NULL,
  buyer_ban                CHAR(8) NULL,
  last_allowance_no        VARCHAR(30) NULL,
  allowance_count          INT NOT NULL DEFAULT 0,

  invoice_status           VARCHAR(10) NOT NULL,
  allowance_status         VARCHAR(10) NOT NULL,
  doc_type                 VARCHAR(10) NOT NULL DEFAULT 'Invoice',
  is_uploaded              BOOLEAN NOT NULL DEFAULT FALSE,

  proof_key                VARCHAR(100) NULL,
  proof_uri                VARCHAR(400) NULL,
  source_system            VARCHAR(20) NULL,
  source_ref               VARCHAR(100) NULL,

  created_at               TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at               TIMESTAMPTZ NOT NULL DEFAULT NOW(),

  CONSTRAINT pk_invoice_archive_header PRIMARY KEY (seller_ban, invoice_no),
  CONSTRAINT ck_tax_type CHECK (tax_type IN (1,2,3,9)),
  CONSTRAINT ck_invoice_status CHECK (invoice_status IN ('Issued','Voided')),
  CONSTRAINT ck_allowance_status CHECK (allowance_status IN ('None','Partial','Full')),
  CONSTRAINT ck_amounts_nonneg CHECK (
    sales_amount >= 0 AND zero_tax_sales_amount >= 0 AND free_tax_sales_amount >= 0 AND
    tax_amount >= 0 AND total_amount >= 0 AND allowance_total_amount >= 0
  )
);

CREATE UNIQUE INDEX IF NOT EXISTS ux_invarch_invoice_key
  ON archive.invoice_archive_header(invoice_key);
CREATE INDEX IF NOT EXISTS ix_invarch_invoice_datetime
  ON archive.invoice_archive_header(invoice_datetime);
CREATE INDEX IF NOT EXISTS ix_invarch_order_no_hash
  ON archive.invoice_archive_header(order_no_hash);
CREATE INDEX IF NOT EXISTS ix_invarch_buyer_ban
  ON archive.invoice_archive_header(buyer_ban);
CREATE INDEX IF NOT EXISTS ix_invarch_status
  ON archive.invoice_archive_header(invoice_status, allowance_status, tax_type);
CREATE INDEX IF NOT EXISTS ix_invarch_batch_id
  ON archive.invoice_archive_header(archive_batch_id);

-- Auto-update updated_at (optional)
CREATE OR REPLACE FUNCTION archive.set_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS tr_invarch_updated_at ON archive.invoice_archive_header;
CREATE TRIGGER tr_invarch_updated_at
BEFORE UPDATE ON archive.invoice_archive_header
FOR EACH ROW EXECUTE FUNCTION archive.set_updated_at();

/* ----------------------------------------------------------
   PostgreSQL partitioning (OPTIONAL)
   - For monthly partitions, convert the table to PARTITIONED and add partitions:
   
   -- Example:
   -- CREATE TABLE archive.invoice_archive_header ( ... ) PARTITION BY RANGE (invoice_datetime);
   -- CREATE TABLE archive.invoice_archive_header_2025_01 PARTITION OF archive.invoice_archive_header
   --   FOR VALUES FROM ('2025-01-01') TO ('2025-02-01');
   
   - Omitted here to keep base DDL copy-paste friendly.
----------------------------------------------------------- */
