/**
 * @package Detox nodes manager
 * @author  Nazar Mokrynskyi <nazar@mokrynskyi.com>
 * @license 0BSD
 */
crypto	= require('crypto')
lib		= require('..')
test	= require('tape')

test('Manager', (t) !->
	nodes	=
		for _ from 0 til 30
			crypto.randomBytes(32)

	bootstrap_nodes	= [
		nodes[0].toString('hex') + '127.0.0.1:433'
		nodes[1].toString('hex') + '127.0.0.1:433'
	]

	manager	= lib(bootstrap_nodes, 10, 0.1)

	manager.add_connected_node(nodes[2])
	manager.add_connected_node(nodes[3])
	manager.add_connected_node(nodes[4])
	manager.add_connected_node(nodes[5])
	manager.add_connected_node(nodes[6])
	manager.add_connected_node(nodes[7])
	manager.add_connected_node(nodes[8])

	manager.once('connected_nodes_count', (count) !->
		t.equal(count, 8, 'Correct number of nodes on addition')

		t.ok(manager.has_connected_node(nodes[9]), 'Node is connected')

		manager.once('connected_nodes_count', (count) !->
			t.equal(count, 7, 'Correct number of nodes on deletion')

			t.equal(manager.get_random_connected_nodes(Infinity).length, 7, 'Correct number of random connected nodes #1')
			t.equal(manager.get_random_connected_nodes(3).length, 3, 'Correct number of random connected nodes #2')

			manager.add_bootstrap_node(nodes[2], bootstrap_nodes[0])

			manager.once('peer_warning', !->
				t.pass('Peer warning generated #1')


				t.equal(manager.get_random_connected_nodes(Infinity).length, 6, 'Correct number of random connected nodes #3')

				t.same(manager.get_bootstrap_nodes(), bootstrap_nodes, 'Got bootstrap nodes correctly')

				t.equal(manager.get_candidates_for_disconnection().length, 7, 'Candidates for disconnection #1')
				t.equal(manager.get_aware_of_nodes(nodes[4]).length, 0, 'Get aware of nodes #1')

				manager.set_peer(nodes[3], nodes.slice(10, 20))

				t.equal(manager.get_candidates_for_disconnection().length, 6, 'Candidates for disconnection #2')
				t.equal(manager.get_aware_of_nodes(nodes[4]).length, 5, 'Get aware of nodes #2')

				t.equal(manager.get_aware_of_nodes(nodes[3]).length, 0, 'Get aware of nodes #3')

				t.ok(manager.more_aware_of_nodes_needed(), 'More aware of nodes needed #1')

				manager.set_aware_of_nodes(nodes[4], nodes.slice(20, 30))

				t.equal(manager.get_aware_of_nodes(nodes[4]).length, 10, 'Get aware of nodes #4')
				t.equal(manager.get_aware_of_nodes(nodes[3]).length, 10, 'Get aware of nodes #5')

				t.notOk(manager.more_aware_of_nodes_needed(), 'More aware of nodes needed #2')

				manager.once('peer_warning', !->
					t.pass('Peer warning generated #2')

					routing_path_nodes	= manager.get_nodes_for_routing_path(3)
					t.equal(routing_path_nodes.length, 3, 'Routing path nodes #1')
					t.ok(manager.has_connected_node(routing_path_nodes[0]), 'Routing path nodes #2')
					t.notOk(manager.has_connected_node(routing_path_nodes[* - 1]), 'Routing path nodes #3')
					t.notEqual(manager.get_nodes_for_routing_path(3), null, 'Routing path nodes #4')
					t.notEqual(manager.get_nodes_for_routing_path(3), null, 'Routing path nodes #5')
					t.notEqual(manager.get_nodes_for_routing_path(3), null, 'Routing path nodes #6')
					t.notEqual(manager.get_nodes_for_routing_path(3), null, 'Routing path nodes #7')
					t.notEqual(manager.get_nodes_for_routing_path(3), null, 'Routing path nodes #8')
					t.equal(manager.get_nodes_for_routing_path(3), null, 'Routing path nodes #9')

					manager.del_first_node_in_routing_path(routing_path_nodes[0])

					t.notEqual(manager.get_nodes_for_routing_path(3), null, 'Routing path nodes #10')

					setTimeout (!->
						t.equal(manager.get_aware_of_nodes(nodes[4]).length, 5, 'Get aware of nodes #6')

						manager.destroy()
						t.end()
					), 500
				)
				manager.set_aware_of_nodes(nodes[3], [nodes[10]])
			)
			manager.add_bootstrap_node(nodes[2], bootstrap_nodes[0])
		)
		manager.del_connected_node(nodes[9])
		t.notOk(manager.has_connected_node(nodes[9]), 'Node is not connected')
	)
	manager.add_connected_node(nodes[9])

)
