Resque with Infinispan cache
============================

This branch shows how Infinispan can be used as cache for Resque.

Testsuite
-----------------
Testsuite runs without error with Infinspan 15+
Step from scratch:

      bundle install
      bundle exec rake infinispan:install
      bundle exec rake infinispan:start
      RESQUE_INFINISPAN=true bundle exec rake test
      # check that testsuite has no error
      bundle exec rake infinispan:stop

Demo
----
Demo can run as is, just start Infinispan before:

        bundle exec rake infinispan:start

then follow the [demo readme](examples/demo/README.markdown)

Cheers!
