export const APP_CONFIG = {
  api: {
    baseUrl: '/api/v1',
    defaultLanguage: 'es',
    supportedLanguages: ['es', 'en'],
    timeout: 15000,
  },
  security: {
    tokenHeader: 'X-API-KEY',
    requireAuth: true,
  },
} as const;
