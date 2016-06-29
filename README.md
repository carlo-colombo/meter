[![Build Status](https://travis-ci.org/carlo-colombo/meter.svg?branch=master)](https://travis-ci.org/carlo-colombo/meter)
[![CircleCI](https://circleci.com/gh/carlo-colombo/meter.svg?style=svg)](https://circleci.com/gh/carlo-colombo/meter)
[![Hex.pm](https://img.shields.io/hexpm/v/meter.svg?style=flat-square)](https://hex.pm/packages/meter)
[![Coverage Status](https://coveralls.io/repos/github/carlo-colombo/meter/badge.svg?branch=master)](https://coveralls.io/github/carlo-colombo/meter?branch=master)


# Meter

  Track your elixir functions on Google Analytics

  This module define one function to track function calls on google analtycs. The functions load parameters from the configuration. Minimum parameter to enable the tracking is :tid (that is the monitoring id from google analytics eg ```UA-12456132-1```). A default ```param_generator``` function is provided to generate the request to google analtycs.

### Configure the module

      config :meter,
        tid: "UA-123123123-1",  #to track functions this is requested
        param_generator: &Meter.Utils.param_generator/5 # the default function, could be replaced,
        mapping: [
          cid: :arg1, # a value to identify the user, is extracted from the function arguments, if not provided GA generate one for each request
          ds: "server", # data source, "server" is the default
          t: "pageview" # hit type, default is "pageview" ],
        custom_dimensions: [:arg1, :arg2] # custom dimensions to send to ga, it mantain the order, to be used need additional configuration on ga

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed as:

  1. Add meter to your list of dependencies in `mix.exs`:

        def deps do
          [{:meter, "~> 0.2.0"}]
        end

  2. Ensure meter is started before your application:

        def application do
          [applications: [:meter]]
        end
