export const ENV = {
  isProduction: process.env.NODE_ENV === "production",
  anthropicApiKey: process.env.BUILT_IN_FORGE_API_KEY ?? process.env.ANTHROPIC_API_KEY ?? "",
};
