import { PrismaClient } from '@prisma/client';

async function main() {
  const prisma = new PrismaClient();
  const roles = await prisma.enmRole.findMany();
  console.log(JSON.stringify(roles, null, 2));
  await prisma.$disconnect();
}

main();
