# Tools of Worship

A simple app for sharing news and prayer requests.

Still being developed, this project contains 2 packages, a flutter app and a service that serves the app and api.

Currently hosting at ToolsOfWorship.com for testing.

Server usage:
> **\-\-https true** To enable https. This will require `server_chain.pem` and `server_key.pem` files in the directory specified by `certificatesUri` in the `properties.dart`.

> **\-\-port \<port\>** To specify which port to listen on. Defaults to 80 for http or 443 if https is specified.

The server hosts the files in the directory specified by `publicUri` in the `properties.dart`.

## License & Copyright
Copyright 2022 Matthew Hale <FillipMatthew@gmail.com>

Licensed under the Apache License, Version 2.0 (the "License"), see [LICENSE](LICENSE).
