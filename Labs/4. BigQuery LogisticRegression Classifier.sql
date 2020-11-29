-- Create ai4f dataset

-- Create model
CREATE OR REPLACE MODEL `ai4f.directionClassifier`
OPTIONS
  (model_type='logistic_reg', input_label_cols=['direction']) AS
SELECT
  symbol,
  close_MIN_prior_5_days,
  close_MIN_prior_20_days,
  close_MAX_prior_5_days,
  close_MAX_prior_20_days,
  direction
FROM
  `cloud-training-prod-bucket.ml4f.percent_change_sp500`
WHERE
  tomorrow_close IS NOT NULL
  AND EXTRACT(year FROM Date) = 2013
  
-- Evaluate the model
SELECT * FROM ML.EVALUATE(MODEL ai4f.directionClassifier,
(
SELECT
  symbol,
  close_MIN_prior_5_days,
  close_MIN_prior_20_days,
  close_MAX_prior_5_days,
  close_MAX_prior_20_days,
  direction
FROM
  `cloud-training-prod-bucket.ml4f.percent_change_sp500`
WHERE
  tomorrow_close IS NOT NULL
  AND EXTRACT(year FROM Date) = 2012
))

-- Predict
SELECT * FROM ML.PREDICT(MODEL ai4f.directionClassifier,
(
SELECT
  Date,
  symbol,
  close_MIN_prior_5_days,
  close_MIN_prior_20_days,
  close_MAX_prior_5_days,
  close_MAX_prior_20_days,
  direction AS ActualDirection
FROM
  `cloud-training-prod-bucket.ml4f.percent_change_sp500`
WHERE
  tomorrow_close IS NOT NULL
  AND EXTRACT(year FROM Date) = 2011
  AND EXTRACT(month FROM Date) = 12
  AND symbol = 'IBM'
))