import { sortBy } from 'common/collections';
import { classes } from 'common/react';
import { capitalize } from 'common/string';
import { useState } from 'react';

import { useBackend } from '../backend';
import { Box, Button, LabeledList, Section, Stack } from '../components';
import { Window } from '../layouts';

type FishingTips = {
  spots: string;
  difficulty: string;
  favorite_bait: string;
  disliked_bait: string;
  traits: string[];
};

type FishInfo = {
  name: string;
  desc: string;
  fluid: string;
  temp_min: number;
  temp_max: number;
  feed: string;
  source: string;
  fishing_tips: FishingTips;
  weight: string;
  size: string;
  icon: string;
};

type FishCatalogData = {
  fish_info: FishInfo[] | null;
  sponsored_by: string;
};

export const FishCatalog = (props) => {
  const { act, data } = useBackend<FishCatalogData>();
  const { fish_info, sponsored_by } = data;
  const fish_by_name = sortBy(fish_info || [], (fish: FishInfo) => fish.name);
  const [currentFish, setCurrentFish] = useState<FishInfo | null>(null);
  return (
    <Window width={500} height={300}>
      <Window.Content>
        <Stack fill>
          <Stack.Item width="140px">
            <Section fill scrollable>
              {fish_by_name.map((f) => (
                <Button
                  key={f.name}
                  fluid
                  color="transparent"
                  selected={f === currentFish}
                  onClick={() => {
                    setCurrentFish(f);
                  }}
                >
                  {f.name}
                </Button>
              ))}
            </Section>
          </Stack.Item>
          <Stack.Item grow basis={0}>
            <Section
              fill
              scrollable
              title={
                currentFish
                  ? capitalize(currentFish.name)
                  : sponsored_by + ' Fish Index'
              }
            >
              {currentFish && (
                <LabeledList>
                  <LabeledList.Item label="描述">
                    {currentFish.desc}
                  </LabeledList.Item>
                  <LabeledList.Item label="水型">
                    {currentFish.fluid}
                  </LabeledList.Item>
                  <LabeledList.Item label="温度">
                    {currentFish.temp_min} to {currentFish.temp_max}
                  </LabeledList.Item>
                  <LabeledList.Item label="鱼食">
                    {currentFish.feed}
                  </LabeledList.Item>
                  <LabeledList.Item label="获取">
                    {currentFish.source}
                  </LabeledList.Item>
                  <LabeledList.Item label="平均尺寸">
                    {currentFish.size} cm
                  </LabeledList.Item>
                  <LabeledList.Item label="平均重量">
                    {currentFish.weight} g
                  </LabeledList.Item>
                  <LabeledList.Item label="垂钓与饲养提示">
                    <LabeledList>
                      <LabeledList.Item label="垂钓地点">
                        {currentFish.fishing_tips.spots}
                      </LabeledList.Item>
                      <LabeledList.Item label="喜好饵食">
                        {currentFish.fishing_tips.favorite_bait}
                      </LabeledList.Item>
                      <LabeledList.Item label="厌恶饵食">
                        {currentFish.fishing_tips.disliked_bait}
                      </LabeledList.Item>
                      <LabeledList.Item label="特性">
                        {currentFish.fishing_tips.traits}
                      </LabeledList.Item>
                    </LabeledList>
                  </LabeledList.Item>
                  <LabeledList.Item label="图像">
                    <Box className={classes(['fish32x32', currentFish.icon])} />
                  </LabeledList.Item>
                </LabeledList>
              )}
            </Section>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};
