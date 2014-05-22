module.exports = (grunt) ->

	[
		'grunt-contrib-coffee'
		'grunt-contrib-concat'
		'grunt-contrib-jasmine'
		'grunt-contrib-sass'
		'grunt-contrib-watch'
		'grunt-ngmin'
	]
	.forEach grunt.loadNpmTasks

	# task sets
	build = ['ngmin', 'concat', 'sass']
	test = ['coffee', 'jasmine']

	# task defs
	grunt.initConfig

		pkg: grunt.file.readJSON 'package.json'

		coffee:
			files:
				'test/test.js': 'test/test.coffee'

		concat:
			main:
				src: ['./bower_components/watch-dom/dist/watch-dom.js', './dist/<%= pkg.name %>.js']
				dest: './dist/<%= pkg.name %>.js'

		jasmine:
			test:
				src: './src/<%= pkg.name %>.js'
				options:
					specs: './test/test.js'
					vendor: [
						'./bower_components/lodash/dist/lodash.js'
						'./bower_components/jquery/dist/jquery.js'
						'./bower_components/angular/angular.js'
						'./bower_components/angular-mocks/angular-mocks.js'
						'./test/mock.js'
					]
					keepRunner: true

		ngmin:
			main:
				src: ['./src/<%= pkg.name %>.js']
				dest: './dist/<%= pkg.name %>.js'

		sass:
			main:
				files:
					'dist/<%= pkg.name %>.css': 'src/<%= pkg.name %>.scss'

		watch:
			main:
				files: './src/*'
				tasks: build
				options:
					interrupt: true
					spawn: false
			test:
				files: './test/*.js'
				tasks: test
				options:
					interrupt: true
					spawn: false

	grunt.registerTask 'default', build
	grunt.registerTask 'test', test
	grunt.registerTask 'travis', ['jasmine']