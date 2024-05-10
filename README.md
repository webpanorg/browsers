# Docker image NodeJS + Browsers

This is a project that contains the source code for the [webpanorg/browsers](https://hub.docker.com/r/webpanorg/browsers) image.
The image works on amd64 and arm64 architectures.
The Dockerfile includes a Nodejs + WebKit, Chromium, Firefox

<p align="center">
    <table width="100%" style="max-width: 500px; margin: 0 auto">
    <tr >
        <td width="20%" valign="center" style="text-align: center;">
            <a target="_blank" rel="noopener noreferrer" href="https://wikipedia.org/wiki/WebKit" alt="WebKit">
                <img src="https://github.com/webpanorg/browsers/blob/assets/chromium.png?raw=true">
            </a>
        </td>
        <td width="20%" valign="center" style="text-align: center;">
            <a target="_blank" rel="noopener noreferrer" href="https://wikipedia.org/wiki/Mozilla_Firefox" alt="Firefox">
                <img  src="https://github.com/webpanorg/browsers/blob/assets/firefox.png?raw=true">
            </a>
        </td>
        <td width="20%" valign="center" style="text-align: center;">
            <a target="_blank" rel="noopener noreferrer" href="https://wikipedia.org/wiki/Chromium" alt="Chromium">
                <img src="https://github.com/webpanorg/browsers/blob/assets/webkit.png?raw=true">
                <br />
            </a>
        </td>
    </tr>
    </table>
</p>

## Description
The image is based on Ubuntu. Images from Playwright are used in the image.
The main reason for not using the official Playwright image is that the browser build versions (revisions) depend on the Playwright version, information which is located in playwright-core/browsers.json.
You can learn more about installing browsers through Playwright here: https://playwright.dev/docs/browsers#install-browsers
Additional packages such as xvfb, ffmpeg, and vnc have been added to the image.

## Example usage image
Example Dockerfile using this image:
```sh
FROM webpanorg/browsers:latest
ENV USER_DIR /home/user

# ----- Add not root user ----- #
ENV USER_ID=999
RUN groupadd -r user && useradd --uid ${USER_ID} -r -g user -G audio,video user
RUN mkdir -p $USER_DIR
RUN chown -R user:user $USER_DIR
RUN chown -R user:user /usr/src
USER user
WORKDIR $USER_DIR

COPY --chown=user src ./src
COPY --chown=user package.json ./package.json
COPY --chown=user tsconfig.json ./tsconfig.json

RUN npm install
# expose vnc
EXPOSE 5900

ENTRYPOINT ["dumb-init", "--"]
CMD ["npm", "run", "start"]
```

## Example code
Example of using Chrome + Puppeteer in Docker:
```ts
import * as puppeteer from 'puppeteer-core';
const DISPLAY = ':99';
(async () => {
    const browser = await puppeteer.launch({
        headless: false,
        executablePath: '/usr/src/chromium/chrome',
        env: {
            DISPLAY
        },
        ignoreDefaultArgs:["--disable-extensions", "--enable-automation"],
        args: [
            "--start-maximized",
            '--window-position=000,000',
            '--window-size=1920,1080',
            '--disable-dev-shm-usage',
            '--no-sandbox',
            '--no-first-run',
            '--no-zygote',
            '--metrics-recording-only',
            '--enable-automation',
            '--mute-audio',
        ],
        defaultViewport: {
            width: 1920,
            height: 1080
        }
    });

    await browser.close();
})();
```

Example of using firefox in Docker:

```ts
import * as playwright from 'playwright-core';
const DISPLAY = ':99';
(async () => {
    const browser = await playwright.firefox.launch({
        headless: false,
        executablePath: '/usr/src/firefox/firefox',
        env: {
            DISPLAY
        },
        args: [
            '--window-position=000,000',
            '-width=1920',
            '-height=1080',
            "--start-maximized"
        ],
    });

    // Create a new incognito browser context.
    const context = await browser.newContext({
        viewport: {
            width: 1920,
            height: 1080
        }
    });

    await context.close();
    await browser.close();
})();
```

Example of using chromium in Docker:

```ts
import * as playwright from 'playwright-core';
const DISPLAY = ':99';
(async () => {
    const browser = await playwright.chromium.launch({
        headless: false,
        executablePath: '/usr/src/chromium/chrome',
        env: {
            DISPLAY
        },
        args: [
            '--window-position=000,000',
            '--window-size=1920,1080',
            "--start-maximized"
        ],
    });

    // Create a new incognito browser context.
    const context = await browser.newContext({
        viewport: {
            width: 1920,
            height: 1080
        }
    });

    await context.close();
    await browser.close();
})();
```

Example of using Webkit in Docker:

```ts
import * as playwright from 'playwright-core';
const DISPLAY = ':99';
(async () => {
    const browser = await playwright.webkit.launch({
        headless: false,
        executablePath: '/usr/src/webkit/pw_run.sh',
        env: {
            DISPLAY
        },
        args: [],
    });

    // Create a new incognito browser context.
    const context = await browser.newContext({
        viewport: {
            width: 1920,
            height: 1080
        }
    });

    await context.close();
    await browser.close();
})();
```

## How to build this image

Clone the repository to your machine. Modify the Dockerfile according to your needs. And create an image based on your Dockerfile.

```sh
docker build -t $name .
```
