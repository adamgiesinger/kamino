## Claws client-side scraper

Implementation of the Claws server-side scraper as a local client using [LiquidCore](https://github.com/LiquidPlayer/LiquidCore/).

### Getting started

- Set up the [Claws repository](https://github.com/ApolloTVofficial/Claws) inside the parent directory of the`kamino` repository, so that the directory structure is as follows:
    ```
    Claws/
    ├── node_modules/
    kamino/
    ├── claws-client/
    │   ├── node_modules/
    │   └── README.md <-- This file
    ```

- Create an `.env` file with the following configuration:
```
# Path to your local claws directory.
CLAWS_DIR=../../Claws
COPY_ASSETS=1
```

- Install all the node dependencies using `npm install`.

- `npm run server` - Create a development server on your development machine, which you can pass into the `MicroService` instance.
    
    On Android:
    - Connect the device to your machine.
    - Forward the server port over to the device: `adb reverse tcp:8082 tcp:8082`. You'll need to have [adb](https://developer.android.com/studio/command-line/adb) installed in your local path.

    On iOS:
    - If you're using the emulator, then the localhost is fine, however if an actual device is being
    used, then you'll want to make sure they're running on the same Wi-Fi network and pass your IP address instead of `localhost`.

    Add `http://localhost:8082/microserver.js` as the URI of the MicroService.

- `npm run bundle:prod` - Bundle the script and add it to the kamino Android/iOS codebase.

