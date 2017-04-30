## Synopsis

Based on the excellent Wippy project by @maximebj, octo for WordPress project aims to fully automatize WordPress management and git each step in specific branches.

## Code Example


For now, this script only check if updates have to be done, create a branch if it's the case and commit after each update to be able to rollback.
To run this octo updates bot, you just have to specify as first parameter the WordPress directory.

```
bash octo-wp.sh /path/to/wordpress/directory
```

## Motivation

Business Agile manages lot of WordPress websites for its customers. To limit energy and time consumptions, we've decided to script what we do everyday with wp-cli.

## Contributors

Contributors :
- [@BiBzz](https://github.com/BiBzz)
- [@askz](https://github.com/askz)

Original idea : [@maximebj](https://twitter.com/maximebj)
