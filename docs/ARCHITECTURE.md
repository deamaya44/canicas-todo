```mermaid
---
title: Canicas TODO - AWS Serverless Architecture
---
graph TB
    %% External Services
    subgraph External["🌐 External Services"]
        User["👤 User"]
        Firebase["🔥 Firebase<br/>Authentication"]
        Cloudflare["☁️ Cloudflare<br/>DNS"]
    end
    
    %% AWS Services
    subgraph AWS["☁️ AWS Account (us-east-1)"]
        
        subgraph Frontend["Frontend Layer"]
            ACM["🔒 ACM<br/>SSL/TLS"]
            CloudFront["🌍 CloudFront<br/>CDN"]
            S3["📦 S3<br/>Static Site"]
        end
        
        subgraph Backend["Backend Layer"]
            APIGW["🚪 API Gateway<br/>HTTP API"]
            AuthLambda["⚡ Lambda<br/>Authorizer"]
            TasksLambda["⚡ Lambda<br/>Tasks API"]
            DynamoDB["🗄️ DynamoDB<br/>Tasks Table"]
        end
        
        subgraph CICD["CI/CD Pipeline"]
            CodeCommit["📝 CodeCommit<br/>Repositories"]
            CodePipeline["🔄 CodePipeline"]
            CodeBuild["🔨 CodeBuild"]
        end
        
        subgraph Security["Security & Config"]
            SSM["🔐 SSM<br/>Parameters"]
            CloudWatch["📊 CloudWatch<br/>Logs"]
            IAM["👥 IAM<br/>Roles"]
        end
    end
    
    %% User Flow
    User -->|1. Auth| Firebase
    User -->|2. DNS Query| Cloudflare
    Cloudflare -->|3. Route| CloudFront
    User -->|4. HTTPS| CloudFront
    
    %% Frontend Flow
    ACM -.->|SSL Cert| CloudFront
    CloudFront -->|5. GET| S3
    CloudFront -->|6. API Call| APIGW
    
    %% Backend Flow
    APIGW -->|7. Verify| AuthLambda
    AuthLambda -.->|Check Token| Firebase
    AuthLambda -.->|Get Config| SSM
    APIGW -->|8. Execute| TasksLambda
    TasksLambda -->|9. Query| DynamoDB
    
    %% Logging
    TasksLambda -.->|Logs| CloudWatch
    AuthLambda -.->|Logs| CloudWatch
    
    %% CI/CD Flow
    CodeCommit -->|Push| CodePipeline
    CodePipeline -->|Build| CodeBuild
    CodeBuild -.->|Deploy| S3
    CodeBuild -.->|Deploy| TasksLambda
    CodeBuild -.->|Read Config| SSM
    
    %% Security
    TasksLambda -.->|Assume| IAM
    AuthLambda -.->|Assume| IAM
    
    %% Styling
    classDef external fill:#fff2cc,stroke:#d6b656,stroke-width:2px
    classDef frontend fill:#e1d5e7,stroke:#9673a6,stroke-width:2px
    classDef backend fill:#d5e8d4,stroke:#82b366,stroke-width:2px
    classDef cicd fill:#ffe6cc,stroke:#d79b00,stroke-width:2px
    classDef security fill:#f8cecc,stroke:#b85450,stroke-width:2px
    
    class User,Firebase,Cloudflare external
    class ACM,CloudFront,S3 frontend
    class APIGW,AuthLambda,TasksLambda,DynamoDB backend
    class CodeCommit,CodePipeline,CodeBuild cicd
    class SSM,CloudWatch,IAM security
```

## 📊 Architecture Overview

**Cost:** $0.00/month (100% AWS Free Tier)

**Components:**
- **External:** Firebase Auth, Cloudflare DNS
- **Frontend:** CloudFront + S3 + ACM
- **Backend:** API Gateway + Lambda (x2) + DynamoDB
- **CI/CD:** CodeCommit + CodePipeline + CodeBuild
- **Security:** SSM + CloudWatch + IAM

**Flow:**
1. User authenticates with Firebase
2. DNS resolves via Cloudflare
3. HTTPS traffic through CloudFront
4. Static content from S3
5. API calls to API Gateway
6. Lambda Authorizer verifies Firebase token
7. Lambda Backend queries DynamoDB
8. All logs to CloudWatch

**Legend:**
- Solid lines (→) = Data flow
- Dashed lines (-.→) = Configuration/Auth
