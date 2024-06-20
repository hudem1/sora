/* Autogenerated file. Do not edit manually. */

import { Account, AccountInterface } from "starknet";
import { DojoProvider } from "@dojoengine/core";
import { Direction } from "../../utils";

export type IWorld = Awaited<ReturnType<typeof setupWorld>>;

export interface MoveProps {
    account: Account | AccountInterface;
    direction: Direction;
}

/*
export interface InitGridProps {
    account: Account | AccountInterface;
    grid_size: number;
}
*/

export async function setupWorld(provider: DojoProvider) {
    function actions() {
        const spawn = async ({ account }: { account: AccountInterface }) => {
            try {
                return await provider.execute(account, {
                    contractName: "actions",
                    entrypoint: "spawn",
                    calldata: [],
                });
            } catch (error) {
                console.error("Error executing spawn:", error);
                throw error;
            }
        };

        const move = async ({ account, direction }: MoveProps) => {
            try {
                return await provider.execute(account, {
                    contractName: "actions",
                    entrypoint: "move",
                    calldata: [direction],
                });
            } catch (error) {
                console.error("Error executing move:", error);
                throw error;
            }
        };

        /*
        const init_grid = async ({ account, grid_size }: InitGridProps) => {
            try {
                return await provider.execute(account, {
                    contractName: "actions",
                    entrypoint: "init_grid",
                    calldata: [grid_size],
                });
            } catch (error) {
                console.error("Error executing init grid:", error);
                throw error;
            }
        }
        */

        return { spawn, move };
    }

    return {
        actions: actions(),
    };
}
