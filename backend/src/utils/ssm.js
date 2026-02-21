const { SSMClient, GetParameterCommand } = require('@aws-sdk/client-ssm');

const ssmClient = new SSMClient({ region: process.env.AWS_REGION || 'us-east-1' });

const getParameter = async (name) => {
  const command = new GetParameterCommand({ Name: name });
  const response = await ssmClient.send(command);
  return response.Parameter.Value;
};

const getFirebaseConfig = async () => {
  try {
    const [apiKey, authDomain, projectId, storageBucket, messagingSenderId, appId] = await Promise.all([
      getParameter('/tasks-3d/firebase/api_key'),
      getParameter('/tasks-3d/firebase/auth_domain'),
      getParameter('/tasks-3d/firebase/project_id'),
      getParameter('/tasks-3d/firebase/storage_bucket'),
      getParameter('/tasks-3d/firebase/messaging_sender_id'),
      getParameter('/tasks-3d/firebase/app_id')
    ]);

    return {
      apiKey,
      authDomain,
      projectId,
      storageBucket,
      messagingSenderId,
      appId
    };
  } catch (error) {
    console.error('Error obteniendo config de Firebase desde SSM:', error);
    throw error;
  }
};

module.exports = { getFirebaseConfig };
