import { filter, sortBy } from 'common/collections';
import { toFixed } from 'common/math';
import { BooleanLike } from 'common/react';

import { useBackend } from '../backend';
import {
  Button,
  NumberInput,
  ProgressBar,
  Section,
  Stack,
} from '../components';
import { Table, TableCell, TableRow } from '../components/Table';
import { getGasColor } from '../constants';
import { Window } from '../layouts';

type Data = {
  bluespace_network_gases: Gas[];
  credits: number;
  inserted_tank: BooleanLike;
  pumping: BooleanLike;
  selected_gas: string;
  tank_amount: number;
  tank_filling_amount: number;
  tank_full: number;
};

type Gas = {
  name: string;
  amount: number;
  price: number;
  id: string;
};

type GasDisplayProps = {
  gas: Gas;
  gasMax: number;
};

export const BluespaceVendor = (props) => {
  const { act, data } = useBackend<Data>();
  const {
    bluespace_network_gases = [],
    inserted_tank,
    pumping,
    tank_amount,
    tank_filling_amount,
    tank_full,
  } = data;

  const gases: Gas[] = sortBy(
    filter(bluespace_network_gases, (gas) => gas.amount >= 0.01),
    (gas) => -gas.amount,
  );

  const gasMax = Math.max(1, ...gases.map((gas) => gas.amount));

  return (
    <Window title="蓝空售货机" width={500} height={600}>
      <Window.Content>
        <Stack vertical fill>
          <Stack.Item>
            <Section
              title="控制"
              buttons={
                <>
                  <Button
                    ml={1}
                    icon="plus"
                    content="准备气瓶"
                    disabled={pumping || inserted_tank || !tank_amount}
                    onClick={() => act('tank_prepare')}
                  />
                  <Button
                    ml={1}
                    icon="minus"
                    content="取出气瓶"
                    disabled={pumping || !inserted_tank}
                    onClick={() => act('tank_expel')}
                  />
                </>
              }
            >
              <Stack>
                <Stack.Item>
                  <NumberInput
                    animated
                    value={tank_filling_amount}
                    step={1}
                    width="63px"
                    unit="% 注瓶目标"
                    minValue={0}
                    maxValue={100}
                    onDrag={(value) =>
                      act('pumping_rate', {
                        rate: value,
                      })
                    }
                  />
                </Stack.Item>
                <Stack.Item grow>
                  {
                    <ProgressBar
                      value={tank_full / 1010}
                      ranges={{
                        good: [0.67, 1],
                        average: [0.34, 0.66],
                        bad: [0, 0.33],
                      }}
                    />
                  }
                </Stack.Item>
              </Stack>
            </Section>
          </Stack.Item>
          <Stack.Item grow>
            <Section
              scrollable
              fill
              title="蓝空网络气体"
              buttons={
                <Button
                  color="transparent"
                  icon="info"
                  tooltipPosition="bottom-start"
                  tooltip={`
                  机器使用快捷指南: 准备气瓶会在机器中创建新气瓶，然后选择你想要填充多少，最后按下你选择的气体开始填充！
                `}
                />
              }
            >
              <Table>
                <thead>
                  <TableRow>
                    <TableCell collapsing bold>
                      气体
                    </TableCell>
                    <TableCell bold collapsing>
                      价格
                    </TableCell>
                    <TableCell bold>Total</TableCell>
                    <TableCell bold collapsing textAlign="right">
                      Moles
                    </TableCell>
                    <TableCell bold collapsing />
                  </TableRow>
                </thead>
                <tbody>
                  {gases.map((gas, index) => (
                    <GasDisplay gasMax={gasMax} gas={gas} key={index} />
                  ))}
                </tbody>
              </Table>
            </Section>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};

const GasDisplay = (props: GasDisplayProps) => {
  const { act, data } = useBackend<Data>();
  const { pumping, selected_gas, inserted_tank } = data;
  const {
    gas: { name, amount, price, id },
    gasMax,
  } = props;

  return (
    <TableRow className="candystripe" height={2}>
      <TableCell collapsing color="label">
        {name}
      </TableCell>
      <TableCell color="yellow" collapsing textAlign="right">
        {price} cr
      </TableCell>
      <TableCell>
        <ProgressBar
          color={getGasColor(id)}
          value={amount}
          minValue={0}
          maxValue={gasMax}
        />
      </TableCell>
      <TableCell collapsing color="label" textAlign="right">
        {toFixed(amount, 2)}
      </TableCell>
      <TableCell collapsing textAlign="center">
        {(!pumping && selected_gas !== id && (
          <Button
            icon="play"
            tooltipPosition="left"
            tooltip={'开始添加 ' + name + '.'}
            disabled={!inserted_tank}
            onClick={() =>
              act('start_pumping', {
                gas_id: id,
              })
            }
          />
        )) || (
          <Button
            disabled={selected_gas !== id}
            icon="minus"
            tooltipPosition="left"
            tooltip={'停止添加 ' + name + '.'}
            onClick={() =>
              act('stop_pumping', {
                gas_id: id,
              })
            }
          />
        )}
      </TableCell>
    </TableRow>
  );
};
