# Import existing CodeCommit repositories
import {
  to = module.codecommit["backend"].aws_codecommit_repository.this
  id = "tasks-3d-prod-backend"
}

import {
  to = module.codecommit["frontend"].aws_codecommit_repository.this
  id = "tasks-3d-prod-frontend"
}

# Import existing S3 bucket
import {
  to = module.s3_buckets["artifacts"].aws_s3_bucket.this
  id = "tasks-3d-prod-artifacts-212950005607"
}
