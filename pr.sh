# npm install @prisma/client@7.10.0 @prisma/adapter-pg dotenv pg
# npm install prisma@7.10.0 tsx @types/pg --save-dev

# npx prisma init --output ../src/generated/prisma

# npx prisma generate

# mkdir -p src/lib && cat > src/lib/prisma.ts <<'EOF'
# import { PrismaClient } from "@/generated/prisma/client";
# import { PrismaPg } from "@prisma/adapter-pg";

# const adapter = new PrismaPg({
#   connectionString: process.env.DATABASE_URL!,
# });

# const globalForPrisma = global as unknown as {
#   prisma: PrismaClient;
# };

# const prisma =
#   globalForPrisma.prisma ||
#   new PrismaClient({
#     adapter,
#   });

# if (process.env.NODE_ENV !== "production") globalForPrisma.prisma = prisma;

# export default prisma;
# EOF

npm install better-auth


SECRET=$(npx auth@latest secret) && sed -i "/^BETTER_AUTH_SECRET=/d;/^BETTER_AUTH_URL=/d" .env && { echo "BETTER_AUTH_SECRET=$SECRET"; echo "BETTER_AUTH_URL=http://localhost:3000"; } >> .env


mkdir -p src/lib && cat > src/lib/auth.ts <<'EOF'
import { betterAuth } from "better-auth";
import { prismaAdapter } from "better-auth/adapters/prisma";
import prisma from "@/lib/prisma";

export const auth = betterAuth({
  database: prismaAdapter(prisma, {
    provider: "postgresql",
  }),
});
EOF


npx auth generate


mkdir -p "src/app/api/auth/[...all]" && cat > "src/app/api/auth/[...all]/route.ts" <<'EOF'
import { auth } from "@/lib/auth";
import { toNextJsHandler } from "better-auth/next-js";

export const { POST, GET } = toNextJsHandler(auth);
EOF


mkdir -p src/lib && cat > src/lib/auth-client.ts <<'EOF'
import { createAuthClient } from "better-auth/react";

export const { signIn, signUp, signOut, useSession } = createAuthClient();
EOF
