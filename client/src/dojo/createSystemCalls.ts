import { AccountInterface } from "starknet";
import { Entity, getComponentValue } from "@dojoengine/recs";
import { uuid } from "@latticexyz/utils";
import { ClientComponents } from "./createClientComponents";
import { Direction, updatePositionWithDirection } from "../utils";
import { getEntityIdFromKeys } from "@dojoengine/utils";
import { ContractComponents } from "./generated/contractComponents";
import type { IWorld } from "./generated/generated";

export type SystemCalls = ReturnType<typeof createSystemCalls>;

export function createSystemCalls(
    { client }: { client: IWorld },
    _contractComponents: ContractComponents,
    { Position, Moves, Tile }: ClientComponents
) {
    const spawn = async (account: AccountInterface) => {
        try {
            const { transaction_hash } = await client.actions.spawn({
                account,
            });

            console.log(
                await account.waitForTransaction(transaction_hash, {
                    retryInterval: 100,
                })
            );

            await new Promise((resolve) => setTimeout(resolve, 1000));
        } catch (e) {
            console.log(e);
        }
    };

    const init_grid = async (account: AccountInterface, grid_size: number) => {
        try {
            const { transaction_hash } = await client.actions.init_grid({
                account,
                grid_size,
            });

            console.log(
                await account.waitForTransaction(transaction_hash, {
                    retryInterval: 100,
                })
            );

            await new Promise((resolve) => setTimeout(resolve, 1000));
        } catch (e) {
            console.log(e);
        }
    };

    const move = async (account: AccountInterface, direction: Direction) => {
        const entityId = getEntityIdFromKeys([
            BigInt(account.address),
        ]) as Entity;

        // const positionId = uuid();
        // Position.addOverride(positionId, {
        //     entity: entityId,
        //     value: {
        //         player: BigInt(entityId),
        //         vec: updatePositionWithDirection(
        //             direction,
        //             getComponentValue(Position, entityId) as any
        //         ).vec,
        //     },
        // });

        // const movesId = uuid();
        // Moves.addOverride(movesId, {
        //     entity: entityId,
        //     value: {
        //         player: BigInt(entityId),
        //         remaining:
        //             (getComponentValue(Moves, entityId)?.remaining || 0) - 1,
        //     },
        // });

        const current_pos = getComponentValue(Position, entityId)!;

        const next_pos = updatePositionWithDirection(direction, current_pos as any);

        const currentTileEntity = getEntityIdFromKeys([
            BigInt(current_pos?.vec.x), BigInt(current_pos.vec.y)
        ]) as Entity;

        const currentTileId = uuid();
        Tile.addOverride(currentTileId, {
            entity: currentTileEntity,
            value: {
                allocated: 'None' as any
            },
        });

        const nextTileEntity = getEntityIdFromKeys([
            BigInt(next_pos?.vec.x), BigInt(next_pos.vec.y)
        ]) as Entity;

        const nextTileId = uuid();
        Tile.addOverride(nextTileId, {
            entity: nextTileEntity,
            value: {
                allocated: 'Some' as any
            },
        });

        try {
            const { transaction_hash } = await client.actions.move({
                account,
                direction,
            });

            await account.waitForTransaction(transaction_hash, {
                retryInterval: 100,
            });

            // console.log(
            //     await account.waitForTransaction(transaction_hash, {
            //         retryInterval: 100,
            //     })
            // );

            await new Promise((resolve) => setTimeout(resolve, 1000));
        } catch (e) {
            console.log(e);
            // Position.removeOverride(positionId);
            // Moves.removeOverride(movesId);
            Tile.removeOverride(currentTileId);
            Tile.removeOverride(nextTileId);
        } finally {
            Tile.removeOverride(currentTileId);
            Tile.removeOverride(nextTileId);
            // Position.removeOverride(positionId);
            // Moves.removeOverride(movesId);
        }
    };

    return {
        spawn,
        move,
        init_grid,
    };
}
