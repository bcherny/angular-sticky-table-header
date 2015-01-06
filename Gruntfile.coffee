module.exports = (grunt) ->

	[
		'grunt-autoprefixer'
		'grunt-contrib-coffee'
		'grunt-contrib-concat'
		'grunt-contrib-jasmine'
		'grunt-contrib-sass'
		'grunt-contrib-watch'
		'grunt-coveralls'
		'grunt-ngmin'
	]
	.forEach grunt.loadNpmTasks

	# task sets
	build = ['ngmin', 'concat', 'sass', 'autoprefixer']
	test = ['coffee', 'jasmine:unit']

	# task defs
	grunt.initConfig

		pkg: grunt.file.readJSON 'package.json'

		autoprefixer:
			options:
				browsers: [
					'Explorer >= 11'
					'last 5 Chrome versions'
					'last 5 Firefox versions'
				]
				cascade: true
			main:
				src: 'dist/<%= pkg.name %>.css'
				dest: 'dist/<%= pkg.name %>.css'

		coffee:
			test: 
				files:
					'test/test.js': 'test/test.coffee'

		concat:
			main:
				src: ['./bower_components/watch-dom/dist/watch-dom.js', './dist/<%= pkg.name %>.js']
				dest: './dist/<%= pkg.name %>.js'

		coveralls:
			options:
				force: true
			main:
				src: 'reports/lcov/lcov.info'

		jasmine:
			coverage:
				src: [
					'./src/<%= pkg.name %>.js'
				]
				options:
					specs: ['./test/test.js']
					template: require 'grunt-template-jasmine-istanbul'
					templateOptions:
						coverage: 'reports/lcov/lcov.json'
						report: [
							{
								type: 'html'
								options:
									dir: 'reports/html'
							}
							{
								type: 'lcov'
								options:
									dir: 'reports/lcov'
							}
						]
					type: 'lcovonly'
					vendor: [
						'./bower_components/lodash/dist/lodash.js'
						'./bower_components/jquery/dist/jquery.js'
						'./bower_components/angular/angular.js'
						'./bower_components/angular-mocks/angular-mocks.js'
						'./test/mock.js'
					]
			unit:
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