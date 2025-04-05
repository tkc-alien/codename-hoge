-- マスタデータスキーマ
CREATE SCHEMA master;

-- アーカイブスキーマ
CREATE SCHEMA archive;

-- 更新日時を自動で適用する関数
CREATE OR REPLACE FUNCTION public.auto_updated_at () RETURNS trigger AS $function$
BEGIN
    NEW.updated_at = now();
    RETURN NEW;
END;
$function$ LANGUAGE plpgsql;

-- 削除レコードを自動でアーカイブする関数
CREATE OR REPLACE FUNCTION public.auto_archive () RETURNS trigger AS $function$
DECLARE
    query TEXT;
BEGIN
    query := 'INSERT INTO archive.' || TG_TABLE_NAME || ' VALUES ($1.*)';
    EXECUTE query USING OLD;
    RETURN OLD;
END;
$function$ LANGUAGE plpgsql;