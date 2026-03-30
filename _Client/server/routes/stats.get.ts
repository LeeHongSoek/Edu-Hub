export default defineEventHandler(() => {
  return {
    stats: {
      questions: 7,
      teachers: 1,
      students: 2,
      parents: 1,
      totalUsers: 4
    },
    timestamp: new Date().toISOString()
  };
});
