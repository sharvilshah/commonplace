require 'rubygems'
require 'sinatra'
require 'sinatra_auth_github'
require File.join(File.dirname(__FILE__), 'lib', 'server')

run CommonplaceServer