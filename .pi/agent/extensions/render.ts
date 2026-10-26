import { Markdown } from "@earendil-works/pi-tui";
import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

type UserMarkdown = Markdown & {
  // These are private implementation fields, used only to identify Pi's
  // user-message Markdown instances (the only Markdown with a background).
  defaultTextStyle?: { bgColor?: (text: string) => string };
};

let theme: { fg(color: "accent", text: string): string } | undefined;
let patched = false;

const originalRender = Markdown.prototype.render;

function isUserMessage(markdown: UserMarkdown): boolean {
  return typeof markdown.defaultTextStyle?.bgColor === "function";
}

function applyPatch(): void {
  if (patched) return;

  Markdown.prototype.render = function renderUserMessageWithAccentBorder(
    this: UserMarkdown,
    width: number,
  ): string[] {
    if (!isUserMessage(this) || width < 2) {
      return originalRender.call(this, width);
    }

    // Render one column narrower, so the rail applies to every visual line,
    // including lines created by Markdown's own wrapping logic.
    const lines = originalRender.call(this, width - 1);
    if (lines.length === 0) return lines;

    const border = theme?.fg("accent", "▏") ?? "▏";
    const withUserBackground = this.defaultTextStyle?.bgColor;
    const styledBorder = withUserBackground ? withUserBackground(border) : border;

    return lines.map((line) => styledBorder + line);
  };

  patched = true;
}

function restorePatch(): void {
  if (!patched) return;
  Markdown.prototype.render = originalRender;
  patched = false;
}

/** Adds an accent-coloured rail to the interactive transcript's user messages. */
export default function (pi: ExtensionAPI): void {
  try {
    applyPatch();
  } catch (error) {
    restorePatch();
    console.error("[user-input-accent-border] Failed to patch Markdown rendering:", error);
  }

  pi.on("session_start", (_event, ctx) => {
    theme = ctx.ui.theme;
    if (!patched) {
      ctx.ui.notify("user-input-accent-border could not be enabled", "error");
      return;
    }

    // Trigger a redraw now that the active theme is available.
    ctx.ui.setWidget("__user_input_accent_border_redraw", []);
    ctx.ui.setWidget("__user_input_accent_border_redraw", undefined);
  });

  pi.on("session_shutdown", restorePatch);
}
