const admin = require('firebase-admin');

// Initialize Firebase Admin
if (!admin.apps.length) {
  admin.initializeApp({
    projectId: process.env.FIREBASE_PROJECT_ID
  });
}

exports.handler = async (event) => {
  console.log('🔐 Authorizer invoked');
  console.log('Headers:', JSON.stringify(event.headers));
  
  try {
    // Step 1: Validate request origin (security layer)
    const allowedOrigins = (process.env.ALLOWED_ORIGINS || '').split(',');
    const origin = event.headers.origin || event.headers.referer;
    
    if (origin) {
      const isAllowedOrigin = allowedOrigins.some(allowed => 
        origin.startsWith(allowed) || origin.includes(allowed)
      );
      
      if (!isAllowedOrigin) {
        console.log('❌ Request from unauthorized origin:', origin);
        return {
          principalId: 'unauthorized',
          policyDocument: {
            Version: '2012-10-17',
            Statement: [{
              Action: 'execute-api:Invoke',
              Effect: 'Deny',
              Resource: '*'
            }]
          }
        };
      }
      console.log('✅ Origin verified:', origin);
    }
    
    // Step 2: Validate Firebase token
    const token = event.headers?.authorization?.replace('Bearer ', '');
    
    if (!token) {
      console.log('❌ No token provided');
      return {
        principalId: 'unauthorized',
        policyDocument: {
          Version: '2012-10-17',
          Statement: [{
            Action: 'execute-api:Invoke',
            Effect: 'Deny',
            Resource: '*'
          }]
        }
      };
    }

    console.log('🔍 Verifying Firebase token...');
    const decodedToken = await admin.auth().verifyIdToken(token);
    console.log('✅ Token verified for user:', decodedToken.uid);
    
    // Return IAM policy with user context
    const response = {
      principalId: decodedToken.uid,
      policyDocument: {
        Version: '2012-10-17',
        Statement: [{
          Action: 'execute-api:Invoke',
          Effect: 'Allow',
          Resource: '*'
        }]
      },
      context: {
        userId: decodedToken.uid,
        email: decodedToken.email || ''
      }
    };
    console.log('📤 Returning:', JSON.stringify(response));
    return response;
  } catch (error) {
    console.error('❌ Auth error:', error.message);
    return {
      principalId: 'unauthorized',
      policyDocument: {
        Version: '2012-10-17',
        Statement: [{
          Action: 'execute-api:Invoke',
          Effect: 'Deny',
          Resource: '*'
        }]
      }
    };
  }
};
