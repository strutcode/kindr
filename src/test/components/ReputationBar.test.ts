import { describe, it, expect } from 'vitest'
import { mount } from '@vue/test-utils'
import ReputationBar from '@/components/common/ReputationBar.vue'

describe('ReputationBar', () => {
  it('renders correctly for unknown reputation', () => {
    const reputation = {
      status: 'unknown' as const,
      positive: 0,
      negative: 0,
      total: 0,
      positivePercentage: 0,
      negativePercentage: 0,
      unknownPercentage: 100,
    }

    const wrapper = mount(ReputationBar, {
      props: { reputation }
    })

    expect(wrapper.text()).toContain('0 interactions')
    expect(wrapper.text()).toContain('Unknown')
  })

  it('renders correctly for known reputation', () => {
    const reputation = {
      status: 'known' as const,
      positive: 80,
      negative: 20,
      total: 100,
      positivePercentage: 80,
      negativePercentage: 20,
      unknownPercentage: 0,
    }

    const wrapper = mount(ReputationBar, {
      props: { reputation }
    })

    expect(wrapper.text()).toContain('100 interactions')
    expect(wrapper.text()).toContain('80 positive')
    expect(wrapper.text()).toContain('20 negative')
  })

  it('displays correct bar widths', () => {
    const reputation = {
      status: 'known' as const,
      positive: 75,
      negative: 25,
      total: 100,
      positivePercentage: 75,
      negativePercentage: 25,
      unknownPercentage: 0,
    }

    const wrapper = mount(ReputationBar, {
      props: { reputation }
    })

    const positiveBar = wrapper.find('.bg-secondary-500')
    const negativeBar = wrapper.find('.bg-error-500')

    expect(positiveBar.attributes('style')).toContain('width: 75%')
    expect(negativeBar.attributes('style')).toContain('width: 25%')
  })
})