# Plugins priority table

The greater the number, the higher the priority of the plugin and it will be loaded first.

| Plugin type          | priority range |
| -------------------- | -------------- |
| Project runtime dirs | 100000         |
| Snacks.nvim          | 15000          |
| Notifications        | 9999-9000      |
| Configuration system | 8999-8000      |

Any plugin that does not matches these category will have the default priority of 50.
