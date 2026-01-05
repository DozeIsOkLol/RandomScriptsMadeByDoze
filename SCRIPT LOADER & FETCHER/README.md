# Universal Script Loader & Fetcher

![Version](https://img.shields.io/badge/Version-2.7-blue.svg)
![License](https://img.shields.io/badge/License-MIT-green.svg)

A professional-grade, robust, and safe utility for fetching, copying, and executing Lua scripts from a wide variety of sources. This tool is designed for client-side executor environments and is built with a focus on security, reliability, and ease of use.

## Features

-   **Config-Driven:** Easily change settings in a clean configuration table without touching the core logic.
-   **Safe by Default:** `AutoExecute` is disabled by default, and numerous warnings prevent accidental execution of untrusted code.
-   **Multi-Platform Support:** Automatically converts standard URLs from popular code-hosting sites into their raw, usable formats.
-   **Resilient Network Logic:** Includes a retry system with delays to handle temporary network failures or rate limits.
-   **Environment-Aware:** Defensively checks for required functions (`HttpGet`, `setclipboard`, `loadstring`) and fails gracefully if they are not available.
-   **Robust Validation:** Protects against common failure points, such as empty responses, HTML error pages, and invalid content types.
-   **Clean and Maintainable:** The architecture is scalable and easy to read, making it simple to add support for more websites in the future.

## Configuration

All user settings are located in the `Config` table at the top of the script.

```lua
local Config = {
    -- The URL to fetch. Must be changed from the default.
    Url = "website here",

    -- If true, automatically tries to execute the fetched script.
    -- ⚠️ SECURITY WARNING: Only enable this if you 100% trust the source.
    AutoExecute = false,

    -- If true, copies the fetched script to the clipboard.
    CopyToClipboard = true,

    -- If true, prints detailed status messages to the console.
    Verbose = true,

    -- --- Advanced Network Settings ---
    -- The number of times to retry a failed web request.
    MaxRetries = 3,

    -- The delay (in seconds) between retries.
    RetryDelay = 2,
}
```

## How to Use

1.  Copy the entire script.
2.  Paste it into your executor.
3.  Change the `Config.Url` to the URL of the script you want to load.
4.  Optionally, change other settings like `AutoExecute` to `true`.
5.  Execute the script and check the console for status messages.

## Supported Websites

The loader will automatically convert standard URLs from the following sites into raw script links:

-   **GitHub** (Repos & Gists)
-   **GitLab**
-   **Bitbucket**
-   **Pastebin**
-   **Paste.ee**
-   **Rentry.co**
-   **ControlC**

If you use a URL from an unsupported site, it must be a direct link to the raw text content.

## Development & Credits

This script began as a simple concept and was iteratively improved into a professional-grade utility through a rigorous process of feedback and refinement. The final version represents a masterclass in defensive programming and user-centric design.

-   **Initial Concept:** User
-   **Architectural Refinement & Code Review:** AI Assistant

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.
