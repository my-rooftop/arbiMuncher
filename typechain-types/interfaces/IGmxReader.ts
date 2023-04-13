/* Autogenerated file. Do not edit manually. */
/* tslint:disable */
/* eslint-disable */
import type {
  BaseContract,
  BigNumber,
  BigNumberish,
  BytesLike,
  CallOverrides,
  PopulatedTransaction,
  Signer,
  utils,
} from "ethers";
import type { FunctionFragment, Result } from "@ethersproject/abi";
import type { Listener, Provider } from "@ethersproject/providers";
import type {
  TypedEventFilter,
  TypedEvent,
  TypedListener,
  OnEvent,
  PromiseOrValue,
} from "../common";

export interface IGmxReaderInterface extends utils.Interface {
  functions: {
    "getAmountOut(address,address,address,uint256)": FunctionFragment;
  };

  getFunction(nameOrSignatureOrTopic: "getAmountOut"): FunctionFragment;

  encodeFunctionData(
    functionFragment: "getAmountOut",
    values: [
      PromiseOrValue<string>,
      PromiseOrValue<string>,
      PromiseOrValue<string>,
      PromiseOrValue<BigNumberish>
    ]
  ): string;

  decodeFunctionResult(
    functionFragment: "getAmountOut",
    data: BytesLike
  ): Result;

  events: {};
}

export interface IGmxReader extends BaseContract {
  connect(signerOrProvider: Signer | Provider | string): this;
  attach(addressOrName: string): this;
  deployed(): Promise<this>;

  interface: IGmxReaderInterface;

  queryFilter<TEvent extends TypedEvent>(
    event: TypedEventFilter<TEvent>,
    fromBlockOrBlockhash?: string | number | undefined,
    toBlock?: string | number | undefined
  ): Promise<Array<TEvent>>;

  listeners<TEvent extends TypedEvent>(
    eventFilter?: TypedEventFilter<TEvent>
  ): Array<TypedListener<TEvent>>;
  listeners(eventName?: string): Array<Listener>;
  removeAllListeners<TEvent extends TypedEvent>(
    eventFilter: TypedEventFilter<TEvent>
  ): this;
  removeAllListeners(eventName?: string): this;
  off: OnEvent<this>;
  on: OnEvent<this>;
  once: OnEvent<this>;
  removeListener: OnEvent<this>;

  functions: {
    getAmountOut(
      _vault: PromiseOrValue<string>,
      _tokenIn: PromiseOrValue<string>,
      _tokenOut: PromiseOrValue<string>,
      _amountIn: PromiseOrValue<BigNumberish>,
      overrides?: CallOverrides
    ): Promise<[BigNumber, BigNumber]>;
  };

  getAmountOut(
    _vault: PromiseOrValue<string>,
    _tokenIn: PromiseOrValue<string>,
    _tokenOut: PromiseOrValue<string>,
    _amountIn: PromiseOrValue<BigNumberish>,
    overrides?: CallOverrides
  ): Promise<[BigNumber, BigNumber]>;

  callStatic: {
    getAmountOut(
      _vault: PromiseOrValue<string>,
      _tokenIn: PromiseOrValue<string>,
      _tokenOut: PromiseOrValue<string>,
      _amountIn: PromiseOrValue<BigNumberish>,
      overrides?: CallOverrides
    ): Promise<[BigNumber, BigNumber]>;
  };

  filters: {};

  estimateGas: {
    getAmountOut(
      _vault: PromiseOrValue<string>,
      _tokenIn: PromiseOrValue<string>,
      _tokenOut: PromiseOrValue<string>,
      _amountIn: PromiseOrValue<BigNumberish>,
      overrides?: CallOverrides
    ): Promise<BigNumber>;
  };

  populateTransaction: {
    getAmountOut(
      _vault: PromiseOrValue<string>,
      _tokenIn: PromiseOrValue<string>,
      _tokenOut: PromiseOrValue<string>,
      _amountIn: PromiseOrValue<BigNumberish>,
      overrides?: CallOverrides
    ): Promise<PopulatedTransaction>;
  };
}
