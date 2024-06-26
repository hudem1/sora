<picture>
  <source media="(prefers-color-scheme: dark)" srcset=".github/mark-dark.svg">
  <img alt="Dojo logo" align="right" width="120" src=".github/mark-light.svg">
</picture>

<a href="https://twitter.com/dojostarknet">
<img src="https://img.shields.io/twitter/follow/dojostarknet?style=social"/>
</a>
<a href="https://github.com/dojoengine/dojo">
<img src="https://img.shields.io/github/stars/dojoengine/dojo?style=social"/>
</a>

[![discord](https://img.shields.io/badge/join-dojo-green?logo=discord&logoColor=white)](https://discord.gg/PwDa2mKhR4)
[![Telegram Chat][tg-badge]][tg-url]

[tg-badge]: https://img.shields.io/endpoint?color=neon&logo=telegram&label=chat&style=flat-square&url=https%3A%2F%2Ftg.sumanjay.workers.dev%2Fdojoengine
[tg-url]: https://t.me/dojoengine

# Dojo Starter: Official Guide

The official Dojo Starter guide, the quickest and most streamlined way to get your Dojo provable game up and running. This guide will assist you with the initial setup, from cloning the repository to deploying your world.

Read the full tutorial [here](https://book.dojoengine.org/tutorial/dojo-starter).

---

## Contribution

This starter project is a constant work in progress and contributions are greatly appreciated!

1. **Report a Bug**

   - If you think you have encountered a bug, and we should know about it, feel free to report it [here](https://github.com/dojoengine/dojo-starter/issues) and we will take care of it.

2. **Request a Feature**

   - You can also request for a feature [here](https://github.com/dojoengine/dojo-starter/issues), and if it's viable, it will be picked for development.

3. **Create a Pull Request**
   - It can't get better then this, your pull request will be appreciated by the community.

Happy coding!





> init grid:
```bash
sozo execute <system_contract_address> init_grid -c 10
```

---

> Grant access for `actions` system contract to write to Tile model: \
> by default, the contract deployer, therefore the person who registered the models, is the owner of the resource. Therefore, we can grant writer access with:
```bash
sozo auth grant writer Tile,0x3610b797baec740e2fa25ae90b4a57d92b04f48a1fdbae1ae203eaf9723c1a0
```
> But in our project, for the `actions` contract, we automatically give writer access to all models in `manifests/dev/overlays/contracts/dojo_starter_systems_actions_actions.toml`.


> to quickly get the state of a Tile:
```bash
sozo model get Tile 5,5
```

> to start the katana json-rpc server:
```bash
katana --disable-fee  --allowed-origins "*"
```

> to start the torii indexer:
```bash
torii --world 0xb4079627ebab1cd3cf9fd075dda1ad2454a7a448bf659591f259efa2519b18 --allowed-origins "*"
```

