## Synopsis

Based on the excellent Wippy project by [@maximebj](https://twitter.com/maximebj), octo for WordPress project aims to fully automatize WordPress management and git each step in specific branches.

## Code Example

For now, the script onlly check if updates have to be done, create a branch if it's the case and commit after each update to be able to rollback. You just have to place yourself in WordPress directory and run octo-wp.sh

```
cd /path/to/wordpress/directory
bash octo-wp.sh
```

## Motivation

Business Agile manages lot of WordPress websites for its customers. To limit energy and time consumptions, we've decided to script what we do everyday with wp-cli.

## Contributors

Contributors : [@BiBzz](https://github.com/BiBzz)
Original idea : [@maximebj](https://twitter.com/maximebj)
