# churn-mlops

پروژه‌ی دوره‌ی MLOps Fundamentals: مدل پیش‌بینی ریزش مشتری (churn).

## Local storage

داده و آرتیفکت‌ها روی یک انبار S3 محلی (SeaweedFS) نگه داشته می‌شوند. برای راه‌اندازی روی لپ‌تاپ خودتان به ترتیب:

1. SeaweedFS را بالا بیاورید. این دستور فقط سرویس `seaweedfs` را روشن می‌کند و وضعیت را نشان می‌دهد؛ صبر کنید `healthy` شود.

```bash
cd ~/mlops-lab/compose && docker compose up -d seaweedfs
docker compose ps
```

2. فایل `.env` را از روی نمونه بسازید. این دستور یک کپی از `.env.example` می‌سازد.

```bash
cd ~/work/churn-mlops && cp .env.example .env
```

بعد با ویرایشگر دو مقدار `CHANGE_ME` را عوض کنید: `AWS_ACCESS_KEY_ID` برابر مقدار `S3_ACCESS_KEY` و `AWS_SECRET_ACCESS_KEY` برابر مقدار `S3_SECRET_KEY` از فایل `~/mlops-lab/compose/.env`. این‌ها کلیدهای آزمایشگاهی‌اند.

3. متغیرهای `.env` را در ترمینال بارگذاری کنید تا AWS CLI نشانی انبار و کلیدها را بشناسد.

```bash
set -a; source .env; set +a
```

4. دو bucket بسازید: `dvc` برای داده‌ها و `mlflow` برای آرتیفکت‌ها. `--endpoint-url` نشانی انبار محلی است؛ بدون آن AWS CLI سراغ Amazon می‌رود.

```bash
uv run aws --endpoint-url "$S3_ENDPOINT_URL" s3 mb s3://dvc
uv run aws --endpoint-url "$S3_ENDPOINT_URL" s3 mb s3://mlflow
```

5. فهرست bucketها را ببینید. این هدف Makefile کلیدها را از `.env` می‌خواند و باید `dvc` و `mlflow` را چاپ کند.

```bash
make s3-ls
```

**چرا `.env` در Git نیست؟** چون کلید واقعی دارد؛ اگر یک بار commit شود تا ابد در تاریخچه‌ی Git می‌ماند و حذف کردنش دشوار است. فقط `.env.example` با مقدار `CHANGE_ME` در Git است و hookهای pre-commit جلوی commit شدن `.env` و کلیدهای داخل کد را می‌گیرند.

### خطاهای رایج

| دستور | پیام خطا | علت و راه‌حل |
|---|---|---|
| `AWS_SECRET_ACCESS_KEY=wrong uv run aws --endpoint-url "$S3_ENDPOINT_URL" s3 ls` | `An error occurred (SignatureDoesNotMatch) when calling the ListBuckets operation: The request signature we calculated does not match the signature you provided. Check your key and signing method.` | secret اشتباه است (غلط املایی، فاصله یا خط اضافه). مقدار را با `~/mlops-lab/compose/.env` مقایسه و `.env` را اصلاح کنید. |
| `uv run aws --endpoint-url http://localhost:8334 s3 ls` | `Could not connect to the endpoint URL: "http://localhost:8334/"` | پورت اشتباه است یا SeaweedFS خاموش است. نشانی باید `http://localhost:8333` باشد؛ `docker compose ps` را ببینید. |
| `docker run -d --name web2 -p 8081:80 nginx:1.28-alpine` (وقتی `web1` همان پورت را دارد) | `Bind for 0.0.0.0:8081 failed: port is already allocated` | پورت لپ‌تاپ را کانتینر دیگری گرفته. با `docker ps` پیدایش کنید یا پورت دیگری بدهید؛ کانتینر ناقص `web2` را با `docker rm -f web2` پاک کنید. |
