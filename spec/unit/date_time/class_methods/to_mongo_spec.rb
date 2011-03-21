require 'spec_helper'

describe DateTime, '.to_mongo' do
  subject { object.to_mongo(value) }

  let(:year)            { 2010                  }
  let(:month)           { 12                    }
  let(:day)             { 31                    }
  let(:minute)          { 59                    }
  let(:second)          { 59                    }
  let(:usec_in_seconds) { Rational(usec, 10**6) }
  let(:object)          { described_class       }

  context 'when the DateTime is UTC' do
    let(:hour)   { 23 }
    let(:offset) { 0  }

    context 'and the microseconds are equal to 0' do
      let(:usec)  { 0                                                                                     }
      let(:value) { DateTime.new(year, month, day, hour, minute, second + usec_in_seconds, offset).freeze }

      it { should == Time.utc(year, month, day, hour, minute, second, usec) }
    end

    # rubinius 1.2.3 has problems with fractional seconds above 59
    unless defined?(RUBY_ENGINE) && RUBY_ENGINE == 'rbx' && Rubinius::VERSION <= '1.2.3'
      context 'and the microseconds are greater than 0' do
        let(:usec)  { 1                                                                                     }
        let(:value) { DateTime.new(year, month, day, hour, minute, second + usec_in_seconds, offset).freeze }

        it { should == Time.utc(year, month, day, hour, minute, second, usec) }
      end
    end
  end

  context 'when the DateTime is not UTC' do
    let(:hour)   { 15               }
    let(:offset) { Rational(-8, 24) }

    context 'and the microseconds are equal to 0' do
      let(:usec)  { 0                                                                                     }
      let(:value) { DateTime.new(year, month, day, hour, minute, second + usec_in_seconds, offset).freeze }

      it { should == Time.utc(year, month, day, 23, minute, second, usec) }
    end

    # rubinius 1.2.3 has problems with fractional seconds above 59
    unless defined?(RUBY_ENGINE) && RUBY_ENGINE == 'rbx' && Rubinius::VERSION <= '1.2.3'
      context 'and the microseconds are greater than 0' do
        let(:usec)  { 1                                                                                     }
        let(:value) { DateTime.new(year, month, day, hour, minute, second + usec_in_seconds, offset).freeze }

        it { should == Time.utc(year, month, day, 23, minute, second, usec) }
      end
    end
  end

end
