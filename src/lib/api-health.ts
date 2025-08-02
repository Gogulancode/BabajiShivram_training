// API Health Check Utility
const API_BASE = 'http://localhost:5001/api';

export const checkAPIHealth = async (): Promise<{ isHealthy: boolean; message: string }> => {
  try {
    // Try to hit a simple endpoint first (modules endpoint)
    const response = await fetch(`${API_BASE}/modules`, {
      method: 'GET',
      headers: {
        'Content-Type': 'application/json',
      },
    });
    
    if (response.ok || response.status === 401) {
      // 200 OK or 401 Unauthorized both mean the server is running
      return { isHealthy: true, message: 'API server is running and accessible' };
    } else if (response.status === 404) {
      return { isHealthy: false, message: 'API server is running but endpoints not found' };
    } else {
      return { isHealthy: false, message: `API server responded with status ${response.status}` };
    }
  } catch (error) {
    if (error instanceof TypeError && (error.message.includes('fetch') || error.message.includes('Failed to fetch'))) {
      return { isHealthy: false, message: 'Cannot connect to API server - server is not running on http://localhost:5001' };
    }
    return { isHealthy: false, message: `API connection error: ${error}` };
  }
};

export const waitForAPI = async (maxAttempts = 10, delayMs = 2000): Promise<boolean> => {
  for (let attempt = 1; attempt <= maxAttempts; attempt++) {
    console.log(`🔄 Checking API connection (attempt ${attempt}/${maxAttempts})...`);
    
    const health = await checkAPIHealth();
    if (health.isHealthy) {
      console.log('✅ API server is ready!');
      return true;
    }
    
    console.log(`❌ API not ready: ${health.message}`);
    
    if (attempt < maxAttempts) {
      console.log(`⏳ Waiting ${delayMs/1000}s before retry...`);
      await new Promise(resolve => setTimeout(resolve, delayMs));
    }
  }
  
  console.log('❌ API server did not become ready within the timeout period');
  return false;
};

export default { checkAPIHealth, waitForAPI };
