import type { ExtensionAPI, ExtensionCommandContext } from "@earendil-works/pi-coding-agent";
import { copyToClipboard, DynamicBorder } from "@earendil-works/pi-coding-agent";
import { Container, type SelectItem, SelectList, Text } from "@earendil-works/pi-tui";

type UserMessage = {
  id: string;
  timestamp: string;
  text: string;
};

function textParts(content: unknown): string {
  if (typeof content === "string") return content;
  if (!Array.isArray(content)) return "";

  return content
    .flatMap((part) => {
      if (!part || typeof part !== "object") return [];
      const value = part as { type?: string; text?: string };
      return value.type === "text" && value.text ? [value.text] : [];
    })
    .join("\n")
    .trim();
}

function userMessages(ctx: ExtensionCommandContext): UserMessage[] {
  return ctx.sessionManager
    .getBranch()
    .flatMap((entry) => {
      if (entry.type !== "message" || entry.message.role !== "user") return [];
      const text = textParts(entry.message.content);
      return text ? [{ id: entry.id, timestamp: entry.timestamp, text }] : [];
    });
}

async function selectMessage(ctx: ExtensionCommandContext, messages: UserMessage[]): Promise<UserMessage | undefined> {
  const items: SelectItem[] = messages.map((message, index) => ({
    value: message.id,
    label: `${index + 1}. ${message.timestamp}`,
    description: message.text.replace(/\s+/g, " ").slice(0, 100),
  }));

  const selectedId = await ctx.ui.custom<string | undefined>((tui, theme, _keybindings, done) => {
    const container = new Container();
    container.addChild(new DynamicBorder((text) => theme.fg("accent", text)));
    container.addChild(new Text(theme.fg("accent", theme.bold("Copy a session message"))));

    const selectList = new SelectList(items, Math.min(items.length, 10), {
      selectedPrefix: (text) => theme.fg("accent", text),
      selectedText: (text) => theme.fg("accent", text),
      description: (text) => theme.fg("muted", text),
      scrollInfo: (text) => theme.fg("dim", text),
      noMatch: (text) => theme.fg("warning", text),
    });
    // Session order is ascending; select the newest, bottom-most message initially.
    selectList.setSelectedIndex(items.length - 1);
    selectList.onSelect = (item) => done(item.value);
    selectList.onCancel = () => done(undefined);
    container.addChild(selectList);
    container.addChild(new Text(theme.fg("dim", "Enter to copy • Esc to cancel")));
    container.addChild(new DynamicBorder((text) => theme.fg("accent", text)));

    return {
      render: (width) => container.render(width),
      invalidate: () => container.invalidate(),
      handleInput: (data) => {
        selectList.handleInput(data);
        tui.requestRender();
      },
    };
  });

  return messages.find((message) => message.id === selectedId);
}

export default function (pi: ExtensionAPI): void {
  pi.registerCommand("messages", {
    description: "Select one of your session messages and copy it to the clipboard",
    handler: async (_args, ctx) => {
      if (ctx.mode !== "tui") {
        ctx.ui.notify("Selecting a message requires Pi's interactive terminal UI.", "warning");
        return;
      }

      const messages = userMessages(ctx);
      if (messages.length === 0) {
        ctx.ui.notify("No text messages from you are available to copy.", "warning");
        return;
      }

      const message = await selectMessage(ctx, messages);
      if (!message) return;

      try {
        await copyToClipboard(message.text);
        ctx.ui.notify(`Copied message ${messages.indexOf(message) + 1} to the clipboard.`, "info");
      } catch (error) {
        ctx.ui.notify(error instanceof Error ? error.message : String(error), "error");
      }
    },
  });
}
