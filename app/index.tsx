import { View, Text, Pressable, StyleSheet } from "react-native";
import { useRouter } from "expo-router";
import { ScreenContainer } from "@/components/screen-container";
import { useColors } from "@/hooks/use-colors";
import * as Haptics from "expo-haptics";
import { Platform } from "react-native";

export default function WelcomeScreen() {
  const router = useRouter();
  const colors = useColors();

  const handleStart = () => {
    if (Platform.OS !== "web") {
      Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Light);
    }
    // @ts-ignore
    router.push("/survey");
  };

  return (
    <ScreenContainer
      containerClassName="bg-background"
      edges={["top", "bottom", "left", "right"]}
    >
      <View style={styles.container}>
        {/* 상단 장식 */}
        <View style={[styles.topDecoration, { backgroundColor: colors.primary }]} />

        {/* 메인 콘텐츠 */}
        <View style={styles.content}>
          {/* 큰 로고 */}
          <View style={[styles.logoContainer, { backgroundColor: colors.accent }]}>
            <Text style={styles.logoEmoji}>💼</Text>
          </View>

          {/* 메인 문구 - 매우 크고 진한 색상 */}
          <Text style={[styles.mainText, { color: colors.foreground }]}>
            일자리 찾고{"\n"}계신가요?
          </Text>
        </View>

        {/* 시작 버튼 */}
        <View style={styles.buttonContainer}>
          <Pressable
            onPress={handleStart}
            style={({ pressed }) => [
              styles.startButton,
              { backgroundColor: colors.primary },
              pressed && { opacity: 0.85, transform: [{ scale: 0.97 }] },
            ]}
          >
            <Text style={styles.startButtonText}>시작하기</Text>
            <Text style={styles.startButtonArrow}>→</Text>
          </Pressable>
        </View>
      </View>
    </ScreenContainer>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    position: "relative",
  },
  topDecoration: {
    position: "absolute",
    top: 0,
    left: 0,
    right: 0,
    height: 200,
    borderBottomLeftRadius: 40,
    borderBottomRightRadius: 40,
    opacity: 0.15,
  },
  content: {
    flex: 1,
    alignItems: "center",
    justifyContent: "center",
    paddingHorizontal: 24,
  },
  logoContainer: {
    width: 140,
    height: 140,
    borderRadius: 36,
    alignItems: "center",
    justifyContent: "center",
    marginBottom: 48,
  },
  logoEmoji: {
    fontSize: 72,
  },
  mainText: {
    fontSize: 48,
    fontWeight: "700",
    textAlign: "center",
    lineHeight: 64,
    letterSpacing: -1,
  },
  buttonContainer: {
    paddingHorizontal: 24,
    paddingBottom: 48,
    alignItems: "center",
    gap: 10,
  },
  startButton: {
    width: "100%",
    height: 68,
    borderRadius: 18,
    flexDirection: "row",
    alignItems: "center",
    justifyContent: "center",
    gap: 10,
  },
  startButtonText: {
    color: "#FFFFFF",
    fontSize: 24,
    fontWeight: "700",
    letterSpacing: 0.3,
  },
  startButtonArrow: {
    color: "#FFFFFF",
    fontSize: 24,
    fontWeight: "700",
  },
});
