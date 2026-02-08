# 🔒 Security Improvements Plan

## Current Security Status

### ✅ Already Implemented
1. **S3 Bucket Protection**
   - ✅ CloudFront Origin Access Control (OAC) configured
   - ✅ S3 bucket policy restricts access to CloudFront only
   - ✅ Public access blocked on S3 bucket
   - ✅ Server-side encryption enabled

2. **Authentication**
   - ✅ Firebase JWT token verification
   - ✅ Lambda authorizer validates all API requests
   - ✅ Per-user data isolation with DynamoDB GSI

3. **IAM & Permissions**
   - ✅ Least privilege IAM roles
   - ✅ No hardcoded credentials
   - ✅ Secrets in AWS SSM Parameter Store

### ⚠️ Security Gaps Identified

1. **API Gateway Direct Access**
   - ❌ API Gateway endpoint is publicly accessible
   - ❌ Anyone can bypass CloudFront and call API directly
   - ❌ No protection against DDoS on API Gateway

2. **Missing WAF Protection**
   - ❌ No AWS WAF on CloudFront
   - ❌ No rate limiting
   - ❌ No protection against common attacks (SQL injection, XSS)

3. **CloudFront Distribution**
   - ❌ CloudFront distribution URL is accessible (should only use custom domain)

## Recommended Security Improvements

### Priority 1: Restrict API Gateway Access to CloudFront Only

**Solution**: Use custom header validation in Lambda authorizer

**Implementation**:
1. Generate a secret value and store in AWS Secrets Manager
2. Configure CloudFront to add custom header `X-Origin-Verify` with secret
3. Update Lambda authorizer to validate this header
4. Reject requests without valid header

**Benefits**:
- API Gateway only accepts requests from CloudFront
- Direct API Gateway URL becomes useless
- Protection against DDoS on API endpoint

**Code Changes**:
```hcl
# terraform: Add custom header to CloudFront origin
resource "aws_cloudfront_distribution" "this" {
  origin {
    custom_header {
      name  = "X-Origin-Verify"
      value = random_password.cloudfront_secret.result
    }
  }
}

# Store secret in Secrets Manager
resource "aws_secretsmanager_secret" "cloudfront_secret" {
  name = "${var.project_name}-${var.environment}-cloudfront-secret"
}
```

```javascript
// Lambda authorizer: Validate custom header
const secretValue = process.env.CLOUDFRONT_SECRET;
const originHeader = event.headers['x-origin-verify'];

if (originHeader !== secretValue) {
  console.log('❌ Invalid origin header');
  return { isAuthorized: false };
}
```

### Priority 2: Add AWS WAF to CloudFront

**Solution**: Enable AWS WAF with managed rule sets

**Implementation**:
1. Create WAF Web ACL
2. Add AWS Managed Rules:
   - AWSManagedRulesCommonRuleSet (OWASP Top 10)
   - AWSManagedRulesKnownBadInputsRuleSet
   - AWSManagedRulesAmazonIpReputationList
3. Add rate limiting rule (100 requests per 5 minutes per IP)
4. Associate WAF with CloudFront distribution

**Benefits**:
- Protection against OWASP Top 10 attacks
- Rate limiting prevents abuse
- IP reputation blocking
- DDoS protection

**Cost**: ~$5-10/month + $0.60 per million requests

### Priority 3: Disable API Gateway Default Endpoint

**Solution**: Disable execute-api endpoint, force custom domain only

**Implementation**:
```hcl
resource "aws_apigatewayv2_api" "this" {
  disable_execute_api_endpoint = true
}
```

**Benefits**:
- Forces all traffic through custom domain (api-dev.amxops.com)
- Custom domain can be fronted by CloudFront for additional protection
- Cleaner architecture

### Priority 4: CloudFront Security Headers

**Solution**: Add security headers via CloudFront Functions

**Implementation**:
```javascript
function handler(event) {
  var response = event.response;
  var headers = response.headers;
  
  headers['strict-transport-security'] = { value: 'max-age=31536000; includeSubdomains; preload'};
  headers['x-content-type-options'] = { value: 'nosniff'};
  headers['x-frame-options'] = { value: 'DENY'};
  headers['x-xss-protection'] = { value: '1; mode=block'};
  headers['referrer-policy'] = { value: 'strict-origin-when-cross-origin'};
  
  return response;
}
```

**Benefits**:
- HSTS prevents downgrade attacks
- XSS protection
- Clickjacking prevention
- Content sniffing prevention

### Priority 5: API Gateway Throttling

**Solution**: Configure usage plans and throttling

**Implementation**:
```hcl
resource "aws_apigatewayv2_stage" "default" {
  throttle_settings {
    burst_limit = 100
    rate_limit  = 50
  }
}
```

**Benefits**:
- Prevents API abuse
- Cost control
- Better resource management

## Implementation Order

1. **Phase 1** (Immediate - No downtime):
   - Add custom header validation to Lambda authorizer
   - Configure CloudFront to send custom header
   - Test thoroughly

2. **Phase 2** (Low risk):
   - Add AWS WAF to CloudFront
   - Configure managed rules
   - Monitor for false positives

3. **Phase 3** (Requires testing):
   - Add CloudFront security headers
   - Configure API Gateway throttling
   - Test application behavior

4. **Phase 4** (Optional):
   - Disable API Gateway default endpoint
   - Front API Gateway with CloudFront (requires architecture change)

## Testing Checklist

- [ ] Verify CloudFront can access API Gateway
- [ ] Verify direct API Gateway access is blocked
- [ ] Test Firebase authentication still works
- [ ] Test all CRUD operations
- [ ] Verify WAF doesn't block legitimate traffic
- [ ] Load test with throttling enabled
- [ ] Check CloudWatch logs for errors

## Monitoring

After implementation, monitor:
- CloudWatch Logs: Lambda authorizer rejections
- WAF Logs: Blocked requests
- API Gateway metrics: 4xx/5xx errors
- CloudFront metrics: Cache hit ratio

## Cost Impact

- WAF: ~$5-10/month + $0.60 per million requests
- Secrets Manager: $0.40/month per secret
- CloudFront Functions: $0.10 per million invocations
- Total estimated: ~$6-12/month additional

## Rollback Plan

If issues occur:
1. Remove custom header validation from authorizer
2. Disable WAF (keep it created for quick re-enable)
3. Re-enable API Gateway default endpoint
4. Remove CloudFront custom headers

All changes are reversible without data loss.
