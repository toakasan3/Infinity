-- Add bounding-box columns to strokes for viewport-aware queries
ALTER TABLE strokes
  ADD COLUMN IF NOT EXISTS min_x FLOAT,
  ADD COLUMN IF NOT EXISTS max_x FLOAT,
  ADD COLUMN IF NOT EXISTS min_y FLOAT,
  ADD COLUMN IF NOT EXISTS max_y FLOAT;

-- Back-fill bounding box for any existing rows
UPDATE strokes
SET
  min_x = (SELECT MIN((pt->>'x')::float) FROM jsonb_array_elements(points) pt),
  max_x = (SELECT MAX((pt->>'x')::float) FROM jsonb_array_elements(points) pt),
  min_y = (SELECT MIN((pt->>'y')::float) FROM jsonb_array_elements(points) pt),
  max_y = (SELECT MAX((pt->>'y')::float) FROM jsonb_array_elements(points) pt)
WHERE min_x IS NULL;

-- Index for efficient spatial queries on strokes
CREATE INDEX IF NOT EXISTS idx_strokes_bounds
  ON strokes (board_code, min_x, max_x, min_y, max_y);
