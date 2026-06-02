import { z } from "zod";
import { router, publicProcedure } from "./_core/trpc";
import { invokeLLM } from "./_core/llm";
import { surveyToNCS, buildPrompt, NCS_REGISTRY } from "../lib/recommendation";
import type { SurveyAnswers, JobRecommendation } from "../lib/recommendation";

export const appRouter = router({
  health: publicProcedure.query(() => ({ status: "ok" })),

  jobs: router({
    recommend: publicProcedure
      .input(
        z.object({
          Q1: z.array(z.string()),
          Q2: z.array(z.string()),
          Q3: z.string(),
          Q4: z.string(),
          Q5: z.string(),
          Q6: z.array(z.string()),
        })
      )
      .mutation(async ({ input }) => {
        const answers: SurveyAnswers = input;
        const ncsResult = surveyToNCS(answers);
        const prompt = buildPrompt(answers, ncsResult);

        try {
          const response = await invokeLLM({
            messages: [
              {
                role: "system",
                content:
                  "당신은 노인 일자리 추천 전문가입니다. 반드시 JSON 형식으로만 응답하세요. JSON 코드 블록(```json)은 제거하고 순수 JSON만 응답하세요.",
              },
              { role: "user", content: prompt },
            ],
            response_format: { type: "json_object" },
          });

          let raw = response.choices[0]?.message?.content ?? "{}";
          
          // content가 배열이면 첫 번째 텍스트 요소 추출
          if (Array.isArray(raw)) {
            const textContent = raw.find((c: any) => c.type === "text") as any;
            raw = textContent?.text ?? "{}";
          }
          
          // 문자열로 변환
          raw = String(raw);
          
          // JSON 코드 블록 제거
          raw = raw.replace(/^```json\s*/i, "").replace(/```\s*$/, "").trim();
          
          let parsed: { recommendations?: JobRecommendation[] };
          try {
            parsed = typeof raw === "string" ? JSON.parse(raw) : (raw as typeof parsed);
          } catch (parseError) {
            console.error("JSON parse error:", parseError, "Raw content:", raw);
            parsed = { recommendations: [] };
          }

          // 응답 검증 및 정제
          const recommendations = (parsed.recommendations ?? [])
            .filter((item: any) => {
              return (
                item &&
                typeof item === "object" &&
                item.rank &&
                item.채용공고명 &&
                item.모집직종 &&
                item.모집요강 &&
                item.reason
              );
            })
            .slice(0, 5) // 최대 5개만
            .map((item: any, idx: number) => ({
              rank: idx + 1,
              채용공고명: String(item.채용공고명 || ""),
              모집직종: String(item.모집직종 || ""),
              모집요강: String(item.모집요강 || ""),
              reason: String(item.reason || ""),
              matchRate: typeof item.matchRate === "number" ? Math.min(100, Math.max(0, item.matchRate)) : undefined,
            }));

          const candidateGroups = [...new Set(
            ncsResult.candidateCodes
              .map((code) => NCS_REGISTRY[code]?.group ?? "")
              .filter(Boolean)
          )];

          return {
            recommendations,
            candidateGroups,
          };
        } catch (error) {
          console.error("Recommendation error:", error);
          // 오류 발생 시에도 빈 추천 목록 반환
          return {
            recommendations: [],
            candidateGroups: [],
          };
        }
      }),
  }),
});

export type AppRouter = typeof appRouter;
