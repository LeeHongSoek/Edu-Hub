export default defineEventHandler((event) => {
  return {
    success: true,
    message: 'Demo API Response',
    data: {
      timestamp: new Date().toISOString(),
      userId: 123,
      userName: 'Test User',
      items: [
        { id: 1, title: 'Item 1', value: 100 },
        { id: 2, title: 'Item 2', value: 200 },
        { id: 3, title: 'Item 3', value: 300 }
      ]
    }
  };
});
