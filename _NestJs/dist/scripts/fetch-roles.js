"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const client_1 = require("@prisma/client");
async function main() {
    const prisma = new client_1.PrismaClient();
    const roles = await prisma.enmRole.findMany();
    console.log(JSON.stringify(roles, null, 2));
    await prisma.$disconnect();
}
main();
//# sourceMappingURL=fetch-roles.js.map