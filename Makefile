.PHONY: data train s3-ls

data:
	uv run python scripts/make_dataset.py

train:
	uv run python -m churn.train --config configs/params.yaml

s3-ls:
	@set -a; . ./.env; set +a; \
	uv run aws --endpoint-url "$$S3_ENDPOINT_URL" s3 ls
