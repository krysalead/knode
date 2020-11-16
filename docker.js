/**
 * @file docker-entry for development container
 */
"use strict";
const { spawn, exec } = require("child_process");

process.on("SIGINT", function () {
  console.log("Process terminating...");
  process.exit(0);
});

/*
 * Restart node when a source file changes, plus:
 * Restart when `npm install` ran based on `package-lock.json` changing.
 */
console.log(
  "===================>DEVELOPMENT START [DEBUG=" +
    process.env.DEBUG +
    "]<======================="
);
/*
 * Install dependencies every time package.json changes
 */
spawn('nodemon -w package.json --exec "npm install"', {
  stdio: "inherit",
  shell: true,
});
spawn("npm run watch", {
  stdio: "inherit",
  shell: true,
});
spawn("npm run dev", {
  stdio: "inherit",
  shell: true,
});
