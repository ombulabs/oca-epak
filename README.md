# oca-epak
Ruby Wrapper for OCA e-Pak API

[![Gem Version](https://badge.fury.io/rb/oca-epak.svg)](http://badge.fury.io/rb/oca-epak)
[![Build Status](https://travis-ci.org/ombulabs/oca-epak.svg?branch=master)](https://travis-ci.org/ombulabs/oca-epak)

## Getting Started

For command line usage:

```bash
$ gem install oca-epak
```

If you intend to use it within an application, add `gem "oca-epak"` to your
`Gemfile`.

## Usage

First, initialize an Oca client:

```ruby
oca = Oca.new("your-email@example.com", "your-password")
```

To check whether your credentials are valid or not, run `#check_credentials`

```ruby
oca.check_credentials
=> true
```

Once you have an operation code from Oca, you can check if it's already active
and available for use by running `#check_operativa`:

```ruby
oca.check_operativa("30-99999999-7", "77790")
=> true
```

NOTE: Keep in mind that you cannot register/create an operation code via Oca's
API, you have to get in touch with someone from Oca and they take care of the
registration.

After you have your operation code active for a given delivery type, you can
begin calculating shipping rates and delivery estimates:

```ruby
opts = { wt: "50", vol: "0.027", origin: "1646", destination: "2000", qty: "1", 
  cuit: "30-99999999-7", op: "77790" }

oca.get_shipping_rates(opts)
=> {:tarifador=>"15",
    :precio=>"328.9000",
    :id_tiposervicio=>"2",
    :ambito=>"Regional",
    :plazo_entrega=>"3",
    :adicional=>"0.0000",
    :total=>"328.9000",
    :xml=>"<row Tarifador=\"15\" Precio=\"328.9000\"/>",
    :"@diffgr:id"=>"Table1",
    :"@msdata:row_order"=>"0"}
```

## Contributing & Development

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Write your feature (and tests)
4. Run tests (`bundle exec rake`)
5. Commit your changes (`git commit -am 'Added some feature'`)
6. Push to the branch (`git push origin my-new-feature`)
7. Create new Pull Request

## Release the Gem

```bash
$ bundle exec rake release
```
