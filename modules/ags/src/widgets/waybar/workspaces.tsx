import AstalHyprland from "gi://AstalHyprland"
import { For, createBinding } from "ags"

export default function Workspaces() {
  const hyprland = AstalHyprland.get_default()
  const workspaces = createBinding(hyprland, "workspaces")
  const focused = createBinding(hyprland, "focusedWorkspace")

  return (
    <box spacing={4}>
      <For each={workspaces((ws: AstalHyprland.Workspace[]) =>
        ws.sort((a, b) => a.id - b.id)
      )}>
        {(workspace: AstalHyprland.Workspace) => (
          <button
            onClicked={() => workspace.focus()}
            css={focused((f) =>
              f?.id === workspace.id
                ? "background: rgba(255,255,255,0.2);"
                : ""
            )}
          >
            <label label={String(workspace.id)} />
          </button>
        )}
      </For>
    </box>
  )
}