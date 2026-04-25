const { Widget } = ags;

export default {
  windows: [
    Widget.Window({
      name: "bar",
      anchor: ["top", "left", "right"],
      child: Widget.Label("Hello AGS"),
    }),
  ],
};