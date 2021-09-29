{ pkgs ? import <nixpkgs> { } }:

with pkgs; let
  source = callPackage ./source.nix { };
  deps = callPackage ./deps.nix { };
in
with pkgs; rec
{
  resholve = callPackage ./resholve.nix {
    inherit (source) rSrc version;
    inherit (deps) binlore;
    inherit (deps.oil) oildev;
  };
  resholve-utils = callPackage ./resholve-utils.nix {
    inherit resholve;
    inherit (deps) binlore;
  };
  resholvePackage = callPackage ./resholve-package.nix {
    inherit resholve resholve-utils;
  };
  resholveScript = name: partialSolution: text:
    writeTextFile {
      inherit name text;
      executable = true;
      checkPhase = ''
        (
          PS4=$'\x1f'"\033[33m[resholve context]\033[0m "
          set -x
          ${resholve-utils.makeInvocation name (partialSolution // {
            scripts = [ "${placeholder "out"}" ];
          })}
        )
        ${partialSolution.interpreter} -n $out
      '';
    };
  resholveScriptBin = name: partialSolution: text:
    writeTextFile rec {
      inherit name text;
      executable = true;
      destination = "/bin/${name}";
      checkPhase = ''
        (
          cd "$out"
          PS4=$'\x1f'"\033[33m[resholve context]\033[0m "
          set -x
          : changing directory to $PWD
          ${resholve-utils.makeInvocation name (partialSolution // {
            scripts = [ "bin/${name}" ];
          })}
        )
        ${partialSolution.interpreter} -n $out/bin/${name}
      '';
    };
}



#include "test.hpp"
36
#include "libtorrent/aux_/session_impl.hpp"
37
#include "libtorrent/string_util.hpp"
38
39
using namespace lt;
40
41
namespace
42
{
43
        using tp = aux::transport;
44
45
        void test_equal(aux::listen_socket_t const& s, address addr, int port
46
                , std::string dev, tp ssl)
47
        {
48
                TEST_CHECK(s.ssl == ssl);
49
                TEST_EQUAL(s.local_endpoint.address(), addr);
50
                TEST_EQUAL(s.original_port, port);
51
                TEST_EQUAL(s.device, dev);
52
        }
53
54
        void test_equal(aux::listen_endpoint_t const& e1, address addr, int port
55
                , std::string dev, tp ssl)
56
        {
57
                TEST_CHECK(e1.ssl == ssl);
58
                TEST_EQUAL(e1.port, port);
59
                TEST_EQUAL(e1.addr, addr);
60
                TEST_EQUAL(e1.device, dev);
61
        }
62
63
        ip_interface ifc(char const* ip, char const* device, char const* netmask = nullptr)
64
        {
65
                ip_interface ipi;
66
                ipi.interface_address = make_address(ip);
67
                if (netmask) ipi.netmask = make_address(netmask);
68
                std::strncpy(ipi.name, device, sizeof(ipi.name) - 1);
69
                return ipi;
70
        }
71
72
        ip_interface ifc(char const* ip, char const* device, interface_flags const flags
73
                , char const* netmask = nullptr)
74
        {
75
                ip_interface ipi;
76
                ipi.interface_address = make_address(ip);
77
                if (netmask) ipi.netmask = make_address(netmask);
78
                std::strncpy(ipi.name, device, sizeof(ipi.name) - 1);
79
                ipi.flags = flags;
80
                return ipi;
81
        }
82
83
        ip_route rt(char const* ip, char const* device, char const* gateway)
84
        {
85
                ip_route ret;
86
                ret.destination = make_address(ip);
87
                ret.gateway = make_address(gateway);
88
                std::strncpy(ret.name, device, sizeof(ret.name) - 1);
89
                ret.name[sizeof(ret.name) - 1] = '\0';
90
                ret.mtu = 1500;
91
                return ret;
92
        }
93
94
        aux::listen_endpoint_t ep(char const* ip, int port
95
                , tp ssl, aux::listen_socket_flags_t const flags)
96
        {
97
                return aux::listen_endpoint_t(make_address(ip), port, std::string{}
98
                        , ssl, flags);
99
        }
100
101
        aux::listen_endpoint_t ep(char const* ip, int port
102
                , tp ssl = tp::plaintext
103
                , std::string device = {})
104
        {
105
                return aux::listen_endpoint_t(make_address(ip), port, device, ssl
106
                        , aux::listen_socket_t::accept_incoming);
107
        }
108
109
        aux::listen_endpoint_t ep(char const* ip, int port
110
                , std::string device
111
                , tp ssl = tp::plaintext)
112
        {
113
                return aux::listen_endpoint_t(make_address(ip), port, device, ssl
114
                        , aux::listen_socket_t::accept_incoming);
115
        }
116
117
        aux::listen_endpoint_t ep(char const* ip, int port
118
                , std::string device
119
                , aux::listen_socket_flags_t const flags)
120
        {
121
                return aux::listen_endpoint_t(make_address(ip), port, device
122
                        , tp::plaintext, flags);
123
        }
124
125
        aux::listen_endpoint_t ep(char const* ip, int port
126
                , aux::listen_socket_flags_t const flags)
127
        {
128
                return aux::listen_endpoint_t(make_address(ip), port, std::string{}
129
                        , tp::plaintext, flags);
130
        }
131
132
        std::shared_ptr<aux::listen_socket_t> sock(char const* ip, int const port
133
                , int const original_port, char const* device = "")
134
        {
135
                auto s = std::make_shared<aux::listen_socket_t>();
136
                s->local_endpoint = tcp::endpoint(make_address(ip)
137
                        , aux::numeric_cast<std::uint16_t>(port));
138
                s->original_port = original_port;
139
                s->device = device;
140
                return s;
141
        }
142
143
        std::shared_ptr<aux::listen_socket_t> sock(char const* ip, int const port, char const* dev)
144
        { return sock(ip, port, port, dev); }
145
146
        std::shared_ptr<aux::listen_socket_t> sock(char const* ip, int const port)
147
        { return sock(ip, port, port); }
148
149
} // anonymous namespace
150
151
TORRENT_TEST(partition_listen_sockets_wildcard2specific)
152
{
153
        std::vector<std::shared_ptr<aux::listen_socket_t>> sockets = {
154
                sock("0.0.0.0", 6881), sock("4.4.4.4", 6881)
155
        };
156
157
        // remove the wildcard socket and replace it with a specific IP
158
        std::vector<aux::listen_endpoint_t> eps = {
159
                ep("4.4.4.4", 6881), ep("4.4.4.5", 6881)
160
        };
161
162
        auto remove_iter = aux::partition_listen_sockets(eps, sockets);
163
        TEST_EQUAL(eps.size(), 1);
164
        TEST_EQUAL(std::distance(sockets.begin(), remove_iter), 1);
165
        TEST_EQUAL(std::distance(remove_iter, sockets.end()), 1);
166
        test_equal(*sockets.front(), make_address_v4("4.4.4.4"), 6881, "", tp::plaintext);
167
        test_equal(*sockets.back(), address_v4(), 6881, "", tp::plaintext);
168
        test_equal(eps.front(), make_address_v4("4.4.4.5"), 6881, "", tp::plaintext);
169
}
170
171
TORRENT_TEST(partition_listen_sockets_port_change)
172
{
173
        std::vector<std::shared_ptr<aux::listen_socket_t>> sockets = {
174
                sock("4.4.4.4", 6881), sock("4.4.4.5", 6881)
175
        };
176
177
        // change the ports
178
        std::vector<aux::listen_endpoint_t> eps = {
179
                ep("4.4.4.4", 6882), ep("4.4.4.5", 6882)
180
        };
181
        auto remove_iter = aux::partition_listen_sockets(eps, sockets);
182
        TEST_CHECK(sockets.begin() == remove_iter);
183
        TEST_EQUAL(eps.size(), 2);
184
}
185
186
TORRENT_TEST(partition_listen_sockets_device_bound)
187
{
188
        std::vector<std::shared_ptr<aux::listen_socket_t>> sockets = {
189
                sock("4.4.4.5", 6881), sock("0.0.0.0", 6881)
190
        };
191
192
        // replace the wildcard socket with a pair of device bound sockets
193
        std::vector<aux::listen_endpoint_t> eps = {
194
                ep("4.4.4.5", 6881)
195
                , ep("4.4.4.6", 6881, "eth1")
196
                , ep("4.4.4.7", 6881, "eth1")
197
        };
198
199
        auto remove_iter = aux::partition_listen_sockets(eps, sockets);
200
        TEST_EQUAL(std::distance(sockets.begin(), remove_iter), 1);
201
        TEST_EQUAL(std::distance(remove_iter, sockets.end()), 1);
202
        test_equal(*sockets.front(), make_address_v4("4.4.4.5"), 6881, "", tp::plaintext);
203
        test_equal(*sockets.back(), address_v4(), 6881, "", tp::plaintext);
204
        TEST_EQUAL(eps.size(), 2);
205
}
206
207
TORRENT_TEST(partition_listen_sockets_device_ip_change)
208
{
209
        std::vector<std::shared_ptr<aux::listen_socket_t>> sockets = {
210
                sock("10.10.10.10", 6881, "enp3s0")
211
                , sock("4.4.4.4", 6881, "enp3s0")
212
        };
213
214
        // change the IP of a device bound socket
215
        std::vector<aux::listen_endpoint_t> eps = {
216
                ep("10.10.10.10", 6881, "enp3s0")
217
                , ep("4.4.4.5", 6881, "enp3s0")
218
        };
219
        auto remove_iter = aux::partition_listen_sockets(eps, sockets);
220
        TEST_EQUAL(std::distance(sockets.begin(), remove_iter), 1);
221
        TEST_EQUAL(std::distance(remove_iter, sockets.end()), 1);
222
        test_equal(*sockets.front(), make_address_v4("10.10.10.10"), 6881, "enp3s0", tp::plaintext);
223
        test_equal(*sockets.back(), make_address_v4("4.4.4.4"), 6881, "enp3s0", tp::plaintext);
224
        TEST_EQUAL(eps.size(), 1);
225
        test_equal(eps.front(), make_address_v4("4.4.4.5"), 6881, "enp3s0", tp::plaintext);
226
}
227
228
TORRENT_TEST(partition_listen_sockets_original_port)
229
{
230
        std::vector<std::shared_ptr<aux::listen_socket_t>> sockets = {
231
                sock("10.10.10.10", 6883, 6881), sock("4.4.4.4", 6883, 6881)
232
        };
233
234
        // make sure all sockets are kept when the actual port is different from the original
235
        std::vector<aux::listen_endpoint_t> eps = {
236
                ep("10.10.10.10", 6881)
237
                , ep("4.4.4.4", 6881)
238
        };
239
240
        auto remove_iter = aux::partition_listen_sockets(eps, sockets);
241
        TEST_CHECK(remove_iter == sockets.end());
242
        TEST_CHECK(eps.empty());
243
}
244
245
TORRENT_TEST(partition_listen_sockets_ssl)
246
{
247
        std::vector<std::shared_ptr<aux::listen_socket_t>> sockets = {
248
                sock("10.10.10.10", 6881), sock("4.4.4.4", 6881)
249
        };
250
251
        // add ssl sockets
252
        std::vector<aux::listen_endpoint_t> eps = {
253
                ep("10.10.10.10", 6881)
254
                , ep("4.4.4.4", 6881)
255
                , ep("10.10.10.10", 6881, tp::ssl)
256
                , ep("4.4.4.4", 6881, tp::ssl)
257
        };
258
259
        auto remove_iter = aux::partition_listen_sockets(eps, sockets);
260
        TEST_CHECK(remove_iter == sockets.end());
261
        TEST_EQUAL(eps.size(), 2);
262
}
263
264
TORRENT_TEST(partition_listen_sockets_op_ports)
265
{
266
        std::vector<std::shared_ptr<aux::listen_socket_t>> sockets = {
267
                sock("10.10.10.10", 6881, 0), sock("4.4.4.4", 6881)
268
        };
269
270
        // replace OS assigned ports with explicit ports
271
        std::vector<aux::listen_endpoint_t> eps ={
272
                ep("10.10.10.10", 6882),
273
                ep("4.4.4.4", 6882),
274
        };
275
        auto remove_iter = aux::partition_listen_sockets(eps, sockets);
276
        TEST_CHECK(remove_iter == sockets.begin());
277
        TEST_EQUAL(eps.size(), 2);
278
}
279
280
TORRENT_TEST(expand_devices)
281
{
282
        std::vector<ip_interface> const ifs = {
283
                ifc("127.0.0.1", "lo", "255.0.0.0")
284
                , ifc("192.168.1.2", "eth0", "255.255.255.0")
285
                , ifc("24.172.48.90", "eth1", "255.255.255.0")
286
                , ifc("::1", "lo", "ffff:ffff:ffff:ffff::")
287
                , ifc("fe80::d250:99ff:fe0c:9b74", "eth0", "ffff:ffff:ffff:ffff::")
288
                , ifc("2601:646:c600:a3:d250:99ff:fe0c:9b74", "eth0", "ffff:ffff:ffff:ffff::")
289
        };
290
291
        std::vector<aux::listen_endpoint_t> eps = {
292
                {
293
                        make_address("127.0.0.1"),
294
                        6881, // port
295
                        "", // device
296
                        aux::transport::plaintext,
297
                        aux::listen_socket_flags_t{} },
298
                {
299
                        make_address("192.168.1.2"),
300
                        6881, // port
301
                        "", // device
302
                        aux::transport::plaintext,
303
                        aux::listen_socket_flags_t{} }
304
        };
305
306
        expand_devices(ifs, eps);
307
308
        TEST_CHECK((eps == std::vector<aux::listen_endpoint_t>{
309
                {
310
                        make_address("127.0.0.1"),
311
                        6881, // port
312
                        "lo", // device
313
                        aux::transport::plaintext,
314
                        aux::listen_socket_flags_t{},
315
                        make_address("255.0.0.0") },
316
                {
317
                        make_address("192.168.1.2"),
318
                        6881, // port
319
                        "eth0", // device
320
                        aux::transport::plaintext,
321
                        aux::listen_socket_flags_t{},
322
                        make_address("255.255.255.0") },
323
                }));
324
}
325
326
TORRENT_TEST(expand_unspecified)
327
{
328
        // this causes us to only expand IPv6 addresses on eth0
329
        std::vector<ip_route> const routes = {
330
                rt("0.0.0.0", "eth0", "1.2.3.4"),
331
                rt("::", "eth0", "1234:5678::1"),
332
        };
333
334
        std::vector<ip_interface> const ifs = {
335
                ifc("127.0.0.1", "lo")
336
                , ifc("192.168.1.2", "eth0")
337
                , ifc("24.172.48.90", "eth1")
338
                , ifc("::1", "lo")
339
                , ifc("fe80::d250:99ff:fe0c:9b74", "eth0")
340
                , ifc("2601:646:c600:a3:d250:99ff:fe0c:9b74", "eth0")
341
        };
342
343
        aux::listen_socket_flags_t const global = aux::listen_socket_t::accept_incoming



Local variable global hides a global variable with the same name.
344
                | aux::listen_socket_t::was_expanded;
345
        aux::listen_socket_flags_t const local = aux::listen_socket_t::accept_incoming



Local variable local hides a global variable with the same name.
346
                | aux::listen_socket_t::was_expanded
347
                | aux::listen_socket_t::local_network;
348
349
        auto v4_nossl      = ep("0.0.0.0", 6881);
350
        auto v4_ssl        = ep("0.0.0.0", 6882, tp::ssl);
351
        auto v4_loopb_nossl= ep("127.0.0.1", 6881, local);
352
        auto v4_loopb_ssl  = ep("127.0.0.1", 6882, tp::ssl, local);
353
        auto v4_g1_nossl   = ep("192.168.1.2", 6881, global);
354
        auto v4_g1_ssl     = ep("192.168.1.2", 6882, tp::ssl, global);
355
        auto v4_g2_nossl   = ep("24.172.48.90", 6881, global);
356
        auto v4_g2_ssl     = ep("24.172.48.90", 6882, tp::ssl, global);
357
        auto v6_unsp_nossl = ep("::", 6883, global);
358
        auto v6_unsp_ssl   = ep("::", 6884, tp::ssl, global);
359
        auto v6_ll_nossl   = ep("fe80::d250:99ff:fe0c:9b74", 6883, local);
360
        auto v6_ll_ssl     = ep("fe80::d250:99ff:fe0c:9b74", 6884, tp::ssl, local);
361
        auto v6_g_nossl    = ep("2601:646:c600:a3:d250:99ff:fe0c:9b74", 6883, global);
362
        auto v6_g_ssl      = ep("2601:646:c600:a3:d250:99ff:fe0c:9b74", 6884, tp::ssl, global);
363
        auto v6_loopb_ssl  = ep("::1", 6884, tp::ssl, local);
364
        auto v6_loopb_nossl= ep("::1", 6883, local);
365
366
        std::vector<aux::listen_endpoint_t> eps = {
367
                v4_nossl, v4_ssl, v6_unsp_nossl, v6_unsp_ssl
368
        };
369
370
        aux::expand_unspecified_address(ifs, routes, eps);
371
372
        TEST_EQUAL(eps.size(), 12);
373
        TEST_CHECK(std::count(eps.begin(), eps.end(), v4_g1_nossl) == 1);
374
        TEST_CHECK(std::count(eps.begin(), eps.end(), v4_g1_ssl) == 1);
375
        TEST_CHECK(std::count(eps.begin(), eps.end(), v4_g2_nossl) == 1);
376
        TEST_CHECK(std::count(eps.begin(), eps.end(), v4_g2_ssl) == 1);
377
        TEST_CHECK(std::count(eps.begin(), eps.end(), v6_ll_nossl) == 1);
378
        TEST_CHECK(std::count(eps.begin(), eps.end(), v6_ll_ssl) == 1);
379
        TEST_CHECK(std::count(eps.begin(), eps.end(), v6_g_nossl) == 1);
380
        TEST_CHECK(std::count(eps.begin(), eps.end(), v6_g_ssl) == 1);
381
        TEST_CHECK(std::count(eps.begin(), eps.end(), v6_loopb_ssl) == 1);
382
        TEST_CHECK(std::count(eps.begin(), eps.end(), v6_loopb_nossl) == 1);
383
        TEST_CHECK(std::count(eps.begin(), eps.end(), v4_loopb_ssl) == 1);
384
        TEST_CHECK(std::count(eps.begin(), eps.end(), v4_loopb_nossl) == 1);
385
        TEST_CHECK(std::count(eps.begin(), eps.end(), v6_unsp_nossl) == 0);
386
        TEST_CHECK(std::count(eps.begin(), eps.end(), v6_unsp_ssl) == 0);
387
        TEST_CHECK(std::count(eps.begin(), eps.end(), v4_nossl) == 0);
388
        TEST_CHECK(std::count(eps.begin(), eps.end(), v4_ssl) == 0);
389
390
        // test that a user configured endpoint is not duplicated
391
        auto v6_g_nossl_dev = ep("2601:646:c600:a3:d250:99ff:fe0c:9b74", 6883, "eth0");
392
393
        eps.clear();
394
        eps.push_back(v6_unsp_nossl);
395
        eps.push_back(v6_g_nossl_dev);
396
397
        aux::expand_unspecified_address(ifs, routes, eps);
398
399
        TEST_EQUAL(eps.size(), 3);
400
        TEST_CHECK(std::count(eps.begin(), eps.end(), v6_ll_nossl) == 1);
401
        TEST_CHECK(std::count(eps.begin(), eps.end(), v6_g_nossl) == 0);
402
        TEST_CHECK(std::count(eps.begin(), eps.end(), v6_loopb_nossl) == 1);
403
        TEST_CHECK(std::count(eps.begin(), eps.end(), v6_g_nossl_dev) == 1);
404
}
405
406
using eps_t =  std::vector<aux::listen_endpoint_t>;
407
408
auto const global = aux::listen_socket_t::accept_incoming
409
        | aux::listen_socket_t::was_expanded;
410
auto const local = global | aux::listen_socket_t::local_network;
411
412
TORRENT_TEST(expand_unspecified_no_default)
413
{
414
        // even though this route isn't a default route, it's a route for a global
415
        // internet address
416
        std::vector<ip_route> const routes = {
417
                rt("128.0.0.0", "eth0", "128.0.0.0"),
418
        };
419
420
        std::vector<ip_interface> const ifs = { ifc("192.168.1.2", "eth0", "255.255.0.0") };
421
        eps_t eps = { ep("0.0.0.0", 6881) };
422
423
        aux::expand_unspecified_address(ifs, routes, eps);
424
425
        TEST_CHECK(eps == eps_t{ ep("192.168.1.2", 6881, global) });
426
}
427
428
namespace {
429
430
void test_expand_unspecified_if_flags(interface_flags const flags
431
        , eps_t const& expected)
432
{
433
        // even though this route isn't a default route, it's a route for a global
434
        // internet address
435
        std::vector<ip_route> const routes = {
436
                rt("0.0.0.0", "eth99", "0.0.0.0"),
437
        };
438
439
        std::vector<ip_interface> const ifs = { ifc("192.168.1.2", "eth0", flags) };
440
        eps_t eps = { ep("0.0.0.0", 6881) };
441
        aux::expand_unspecified_address(ifs, routes, eps);
442
        TEST_CHECK((eps == expected));
443
}
444
445
void test_expand_unspecified_if_address(char const* address, eps_t const& expected)
446
{
447
        std::vector<ip_route> const routes;
448
        std::vector<ip_interface> const ifs = { ifc(address, "eth0", "255.255.0.0") };
449
        eps_t eps = { ep("0.0.0.0", 6881) };
450
451
        aux::expand_unspecified_address(ifs, routes, eps);
452
453
        TEST_CHECK(eps == expected);
454
}
455
456
}
457
458
TORRENT_TEST(expand_unspecified_ppp)
459
{
460
        test_expand_unspecified_if_flags(if_flags::up | if_flags::pointopoint, eps_t{ ep("192.168.1.2", 6881, global) });
461
        test_expand_unspecified_if_flags(if_flags::up, eps_t{ ep("192.168.1.2", 6881, local) });
462
}
463
464
TORRENT_TEST(expand_unspecified_down_if)
465
{
466
        test_expand_unspecified_if_flags({}, eps_t{});
467
        test_expand_unspecified_if_flags(if_flags::up, eps_t{ ep("192.168.1.2", 6881, local) });
468
}
469
470
TORRENT_TEST(expand_unspecified_if_loopback)
471
{
472
        test_expand_unspecified_if_flags(if_flags::up | if_flags::loopback, eps_t{ ep("192.168.1.2", 6881, local) });
473
}
474
475
TORRENT_TEST(expand_unspecified_global_address)
476
{
477
        test_expand_unspecified_if_address("1.2.3.4", eps_t{ ep("1.2.3.4", 6881, global)});
478
}
479
480
TORRENT_TEST(expand_unspecified_link_local)
481
{
482
        test_expand_unspecified_if_address("169.254.1.2", eps_t{ ep("169.254.1.2", 6881, local)});
483
}
484
485
TORRENT_TEST(expand_unspecified_loopback)
486
{
487
        test_expand_unspecified_if_address("127.1.1.1", eps_t{ ep("127.1.1.1", 6881, local)});
488
}
489
490
namespace {
491
std::vector<aux::listen_endpoint_t> to_endpoint(listen_interface_t const& iface
492
        , span<ip_interface const> const ifs)
493
{
494
        std::vector<aux::listen_endpoint_t> ret;
495
        interface_to_endpoints(iface, aux::listen_socket_t::accept_incoming, ifs, ret);
496
        return ret;
497
}
498
499
using eps = std::vector<aux::listen_endpoint_t>;
500
501
listen_interface_t ift(char const* dev, int const port, bool const ssl = false
502
        , bool const l= false)
503
{
504
        return {std::string(dev), port, ssl, l};
505
}
506
}
507
using ls = aux::listen_socket_t;
508
509
TORRENT_TEST(interface_to_endpoint)
510
{
511
        TEST_CHECK(to_endpoint(ift("10.0.1.1", 6881), {}) == eps{ep("10.0.1.1", 6881)});
512
513
514
        std::vector<ip_interface> const ifs = {
515
                // this is a global IPv4 address, not a private network
516
                ifc("185.0.1.2", "eth0")
517
                , ifc("192.168.2.2", "eth1")
518
                , ifc("fe80::d250:99ff:fe0c:9b74", "eth0")
519
                // this is a global IPv6 address, not a private network
520
                , ifc("2601:646:c600:a3:d250:99ff:fe0c:9b74", "eth1")
521
        };
522
523
        TEST_CHECK((to_endpoint(ift("eth0", 1234), ifs)
524
                == eps{ep("185.0.1.2", 1234, "eth0", ls::was_expanded | ls::accept_incoming)
525
                , ep("fe80::d250:99ff:fe0c:9b74", 1234, "eth0", ls::was_expanded | ls::accept_incoming | ls::local_network)}));
526
527
        TEST_CHECK((to_endpoint(ift("eth1", 1234), ifs)
528
                == eps{ep("192.168.2.2", 1234, "eth1", ls::was_expanded | ls::accept_incoming)
529
                , ep("2601:646:c600:a3:d250:99ff:fe0c:9b74", 1234, "eth1", ls::was_expanded | ls::accept_incoming)}));
530

import to mu
