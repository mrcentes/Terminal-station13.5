import { createSearch, toTitleCase } from 'common/string';
import { useState } from 'react';

import { useBackend, useSharedState } from '../backend';
import {
  BlockQuote,
  Box,
  Button,
  Icon,
  Image,
  Input,
  LabeledList,
  Section,
  Stack,
  Table,
  Tabs,
} from '../components';
import { formatSiUnit } from '../format';
import { Window } from '../layouts';

export const OreRedemptionMachine = (props) => {
  const { act, data } = useBackend();
  const { disconnected, unclaimedPoints, materials, user } = data;
  const [tab, setTab] = useSharedState('tab', 1);
  const [searchItem, setSearchItem] = useState('');
  const [compact, setCompact] = useState(false);
  const search = createSearch(searchItem, (materials) => materials.name);
  const material_filtered =
    searchItem.length > 0
      ? data.materials.filter(search)
      : materials.filter((material) => material && material.category === tab);

  return (
    <Window title="矿石回收机" width={435} height={500}>
      <Window.Content>
        <Stack fill vertical>
          <Section>
            <Stack.Item>
              <Section>
                <Stack>
                  <Stack.Item>
                    <Icon
                      name="id-card"
                      size={3}
                      mr={1}
                      color={user ? 'green' : 'red'}
                    />
                  </Stack.Item>
                  <Stack.Item>
                    <LabeledList>
                      <LabeledList.Item label="姓名">
                        {user?.name || '未检测到姓名'}
                      </LabeledList.Item>
                      <LabeledList.Item label="余额">
                        {user?.cash || '未检测到余额'}
                      </LabeledList.Item>
                    </LabeledList>
                  </Stack.Item>
                  <Stack.Item>
                    <Button
                      textAlign="center"
                      color={compact ? 'red' : 'green'}
                      content="简洁视图"
                      onClick={() => setCompact(!compact)}
                    />
                  </Stack.Item>
                </Stack>
              </Section>
            </Stack.Item>
          </Section>
          <Section>
            <Stack.Item>
              <Box>
                <Icon name="coins" color="gold" />
                <Box inline color="label" ml={1}>
                  未认领点数:
                </Box>
                {unclaimedPoints}
                <Button
                  ml={2}
                  content="认领"
                  disabled={unclaimedPoints === 0 || disconnected}
                  tooltip={disconnected}
                  onClick={() => act('Claim')}
                />
              </Box>
            </Stack.Item>
          </Section>
          <Section>
            <Stack.Item>
              <BlockQuote>此机器只接收矿石，爆裂闪矿和矿渣恕不接受.</BlockQuote>
            </Stack.Item>
          </Section>
          <Tabs>
            <Tabs.Tab
              icon="list"
              lineHeight="23px"
              selected={tab === 'material'}
              onClick={() => {
                setTab('material');

                if (searchItem.length > 0) {
                  setSearchItem('');
                }
              }}
            >
              原料
            </Tabs.Tab>
            <Tabs.Tab
              icon="list"
              lineHeight="23px"
              selected={tab === 'alloy'}
              onClick={() => {
                setTab('alloy');

                if (searchItem.length > 0) {
                  setSearchItem('');
                }
              }}
            >
              合金
            </Tabs.Tab>
            <Input
              autofocus
              position="relative"
              left="25%"
              bottom="5%"
              height="20px"
              width="150px"
              placeholder="搜索原料..."
              value={searchItem}
              onInput={(e, value) => {
                setSearchItem(value);

                if (value.length > 0) {
                  setTab(1);
                }
              }}
              fluid
            />
          </Tabs>
          <Stack.Item grow>
            <Section fill scrollable>
              <Table>
                {material_filtered.map((material) => (
                  <MaterialRow
                    compact={compact}
                    key={material.id}
                    material={material}
                    onRelease={(amount) => {
                      if (material.category === 'material') {
                        act('Release', {
                          id: material.id,
                          sheets: amount,
                        });
                      } else {
                        act('Smelt', {
                          id: material.id,
                          sheets: amount,
                        });
                      }
                    }}
                  />
                ))}
              </Table>
            </Section>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};

const MaterialRow = (props) => {
  const { data } = useBackend();
  const { compact } = props;
  const { material_icons } = data;
  const { material, onRelease } = props;

  const display = material_icons.find(
    (mat_icon) => mat_icon.id === material.id,
  );

  const sheet_amounts = Math.floor(material.amount);
  const print_amount = 5;
  const max_sheets = 50;

  return (
    <Table.Row className="candystripe" collapsing>
      {!compact && (
        <Table.Cell collapsing>
          <Image
            m={1}
            src={`data:image/jpeg;base64,${display.product_icon}`}
            height="18px"
            width="18px"
            style={{
              verticalAlign: 'middle',
            }}
          />
        </Table.Cell>
      )}
      <Table.Cell>{toTitleCase(material.name)}</Table.Cell>
      <Table.Cell collapsing textAlign="left">
        <Box color="label">{formatSiUnit(sheet_amounts, 0)} 份板材</Box>
      </Table.Cell>
      <Table.Cell collapsing textAlign="left">
        <Button
          content="x1"
          color="transparent"
          tooltip={material.value ? material.value + 'cr' : '无花费'}
          onClick={() => onRelease(1)}
        />
        <Button
          content={'x' + print_amount}
          color="transparent"
          tooltip={
            material.value ? material.value * print_amount + 'cr' : '无花费'
          }
          onClick={() => onRelease(print_amount)}
        />
        <Button.Input
          content={
            '[最大值: ' +
            (sheet_amounts < max_sheets ? sheet_amounts : max_sheets) +
            ']'
          }
          color={'transparent'}
          maxValue={max_sheets}
          onCommit={(e, value) => {
            onRelease(value);
          }}
        />
      </Table.Cell>
    </Table.Row>
  );
};
