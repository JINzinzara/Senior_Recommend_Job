import { createTRPCReact } from "@trpc/react-query";
import { httpBatchLink } from "@trpc/client";
import superjson from "superjson";
import type { AppRouter } from "@/server/routers";
import Constants from "expo-constants";

export const trpc = createTRPCReact<AppRouter>();

function getApiBaseUrl(): string {
  const debuggerHost = Constants.expoConfig?.hostUri;
  const host = debuggerHost?.split(":")[0];
  if (host) return `http://${host}:3000`;
  return "http://localhost:3000";
}

export function createTRPCClient() {
  return trpc.createClient({
    links: [
      httpBatchLink({
        url: `${getApiBaseUrl()}/api/trpc`,
        transformer: superjson,
      }),
    ],
  });
}
