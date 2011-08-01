# The picbuild Image Compiler

Picbuild is a small experiment in image workflow management for Xcode projects. By using picbuild, you can decouple the image 'sources' — the raw files you're using to produce your actual icons — from the produced files in your app bundle.

To use picbuild:

* Add a new build rule to your Xcode project as follows:
    * *Process* **Source files with names matching: '*.picbuild'**
    * *Using* **Custom Script:**
			
			mkdir -p "$BUILT_PRODUCTS_DIR"/"$UNLOCALIZED_RESOURCES_FOLDER_PATH"
			
			picbuild "$INPUT_FILE_PATH" "$BUILT_PRODUCTS_DIR"/"$UNLOCALIZED_RESOURCES_FOLDER_PATH"
			touch "$DERIVED_FILES_DIR/$INPUT_FILE_BASE.picbuild-done"
			
	* *Output Files*: `$(DERIVED_FILES_DIR)/$(INPUT_FILE_BASE).picbuild-done` 

Use the full path to your `picbuild` installation in your custom script above.

* Copy the sample bundle (`iOS Icon.image`) and customize its `.picbuild` file as you need.

* Add source image files to the bundle.

* Add the .picbuild file inside the bundle to your Xcode project's Compile Sources phase.

Each item in the `imageFactories` key of the `.picbuild` will produce a file in the resources directory of your bundle. The best source image for the job is picked automatically, and it's then copied, resized (if needed) and saved in the correct format.

This allows you to start with a single placeholder image, and then refine and add other images in the `.image` bundle as needed. The compiler will pick up on these modifications without having to produce those manually or alter the Xcode project.

This is a work in progress and mostly undocumented. See the source for more information.