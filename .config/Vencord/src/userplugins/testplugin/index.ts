import definePlugin from "@utils/types";

export default definePlugin({
    name: "Epic Plugin",
    description: "This plugin is absolutely epic",
    authors: [
        {
            id: 0n,
            name: "Dasam",
        },
    ],
    patches: [],
    // Delete these two below if you are only using code patches
    start() {},
    stop() {},
});