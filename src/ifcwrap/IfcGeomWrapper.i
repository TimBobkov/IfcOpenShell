/********************************************************************************
 *                                                                              *
 * This file is part of IfcOpenShell.                                           *
 *                                                                              *
 * IfcOpenShell is free software: you can redistribute it and/or modify         *
 * it under the terms of the Lesser GNU General Public License as published by  *
 * the Free Software Foundation, either version 3.0 of the License, or          *
 * (at your option) any later version.                                          *
 *                                                                              *
 * IfcOpenShell is distributed in the hope that it will be useful,              *
 * but WITHOUT ANY WARRANTY; without even the implied warranty of               *
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the                 *
 * Lesser GNU General Public License for more details.                          *
 *                                                                              *
 * You should have received a copy of the Lesser GNU General Public License     *
 * along with this program. If not, see <http://www.gnu.org/licenses/>.         *
 *                                                                              *
 ********************************************************************************/

%rename("settings") IteratorSettings;

// This is only used for RGB colours, hence the size of 3
%typemap(out) const double* {
	$result = PyTuple_New(3);
	for (int i = 0; i < 3; ++i) {
		PyTuple_SetItem($result, i, PyFloat_FromDouble($1[i]));
	}
}

// SWIG does not support bool references in a meaningful way, so the
// IfcGeom::IteratorSettings functions degrade to return a read only value
%typemap(out) double& {
	$result = SWIG_From_double(*$1);
}
%typemap(out) bool& {
	$result = PyBool_FromLong(static_cast<long>(*$1));
}

%include "../ifcgeom/IfcGeomIteratorSettings.h"
%include "../ifcgeom/IfcGeomElement.h"
%include "../ifcgeom/IfcGeomMaterial.h"
%include "../ifcgeom/IfcGeomRepresentation.h"
%include "../ifcgeom/IfcGeomIterator.h"

// Using RTTI return a more specialized type of Element
// Note that these elements are not to be owned by SWIG/Python as they will be freed automatically upon the next iteration
// except for the IfcGeom::Element instances which are returned by Iterator::getObject() calls
%typemap(out) IfcGeom::Element<float>* {
	IfcGeom::SerializedElement<float>* serialized_elem = dynamic_cast<IfcGeom::SerializedElement<float>*>($1);
	IfcGeom::TriangulationElement<float>* triangulation_elem = dynamic_cast<IfcGeom::TriangulationElement<float>*>($1);
	if (triangulation_elem) {
		$result = SWIG_NewPointerObj(SWIG_as_voidptr(triangulation_elem), SWIGTYPE_p_IfcGeom__TriangulationElementT_float_t, 0);
	} else if (serialized_elem) {
		$result = SWIG_NewPointerObj(SWIG_as_voidptr(serialized_elem), SWIGTYPE_p_IfcGeom__SerializedElementT_float_t, 0);
	} else {
		$result = SWIG_NewPointerObj(SWIG_as_voidptr($1), SWIGTYPE_p_IfcGeom__ElementT_float_t, SWIG_POINTER_OWN);
	}
}

// Using RTTI return a more specialized type of Element
// Note that these elements are not to be owned by SWIG/Python as they will be freed automatically upon the next iteration
// except for the IfcGeom::Element instances which are returned by Iterator::getObject() calls
%typemap(out) IfcGeom::Element<double>* {
	IfcGeom::SerializedElement<double>* serialized_elem = dynamic_cast<IfcGeom::SerializedElement<double>*>($1);
	IfcGeom::TriangulationElement<double>* triangulation_elem = dynamic_cast<IfcGeom::TriangulationElement<double>*>($1);
	if (triangulation_elem) {
		$result = SWIG_NewPointerObj(SWIG_as_voidptr(triangulation_elem), SWIGTYPE_p_IfcGeom__TriangulationElementT_double_t, 0);
	} else if (serialized_elem) {
		$result = SWIG_NewPointerObj(SWIG_as_voidptr(serialized_elem), SWIGTYPE_p_IfcGeom__SerializedElementT_double_t, 0);
	} else {
		$result = SWIG_NewPointerObj(SWIG_as_voidptr($1), SWIGTYPE_p_IfcGeom__ElementT_double_t, SWIG_POINTER_OWN);
	}
}

// Note that these elements ARE to be owned by SWIG/Python
%typemap(out) boost::variant<IfcGeom::Element<double>*, IfcGeom::Representation::Representation*> {
	// See which type is set and return appropriate
	IfcGeom::Element<double>* elem = boost::get<IfcGeom::Element<double>*>($1);
	IfcGeom::SerializedElement<double>* serialized_elem = dynamic_cast<IfcGeom::SerializedElement<double>*>(elem);
	IfcGeom::TriangulationElement<double>* triangulation_elem = dynamic_cast<IfcGeom::TriangulationElement<double>*>(elem);
	if (triangulation_elem) {
		$result = SWIG_NewPointerObj(SWIG_as_voidptr(triangulation_elem), SWIGTYPE_p_IfcGeom__TriangulationElementT_double_t, SWIG_POINTER_OWN);
	} else if (serialized_elem) {
		$result = SWIG_NewPointerObj(SWIG_as_voidptr(serialized_elem), SWIGTYPE_p_IfcGeom__SerializedElementT_double_t, SWIG_POINTER_OWN);
	}
}

// This does not seem to work:
%ignore IfcGeom::Iterator<float>::Iterator(const IfcGeom::IteratorSettings&, IfcParse::IfcFile*);
%ignore IfcGeom::Iterator<float>::Iterator(const IfcGeom::IteratorSettings&, void*, int);
%ignore IfcGeom::Iterator<float>::Iterator(const IfcGeom::IteratorSettings&, std::istream&, int);
%ignore IfcGeom::Iterator<double>::Iterator(const IfcGeom::IteratorSettings&, IfcParse::IfcFile*);
%ignore IfcGeom::Iterator<double>::Iterator(const IfcGeom::IteratorSettings&, void*, int);
%ignore IfcGeom::Iterator<double>::Iterator(const IfcGeom::IteratorSettings&, std::istream&, int);

// Ignore the std::vector accessors and replace them to pairs that will
// be expanded to Python tuples by means of typemaps. This in order to
// minimize passing STL objects across dynamic library boundaries.
%ignore IfcGeom::Representation::Triangulation::verts;
%ignore IfcGeom::Representation::Triangulation::faces;
%ignore IfcGeom::Representation::Triangulation::edges;
%ignore IfcGeom::Representation::Triangulation::normals;
%ignore IfcGeom::Representation::Triangulation::material_ids;
%ignore IfcGeom::Representation::Triangulation::materials;
%extend IfcGeom::Representation::Triangulation {
	std::pair<const int*, unsigned> get_faces() {
		return std::make_pair(&$self->faces()[0], $self->faces().size());
	}
	std::pair<const int*, unsigned> get_edges() {
		return std::make_pair(&$self->edges()[0], $self->edges().size());
	}
	std::pair<const int*, unsigned> get_material_ids() {
		return std::make_pair(&$self->material_ids()[0], $self->material_ids().size());
	}
	std::pair<const IfcGeom::Material*, unsigned> get_materials() {
		return std::make_pair(&$self->materials()[0], $self->materials().size());
	}
}
%extend IfcGeom::Representation::Triangulation<float> {
	std::pair<const float*, unsigned> get_verts() {
		return std::make_pair(&$self->verts()[0], $self->verts().size());
	}
	std::pair<const float*, unsigned> get_normals() {
		return std::make_pair(&$self->normals()[0], $self->normals().size());
	}
}
%extend IfcGeom::Representation::Triangulation<double> {
	std::pair<const double*, unsigned> get_verts() {
		return std::make_pair(&$self->verts()[0], $self->verts().size());
	}
	std::pair<const double*, unsigned> get_normals() {
		return std::make_pair(&$self->normals()[0], $self->normals().size());
	}
}
	

%extend IfcGeom::IteratorSettings {
	%pythoncode %{
		attrs = ("convert_back_units", "deflection_tolerance", "disable_opening_subtractions", "disable_triangulation", "faster_booleans", "sew_shells", "use_brep_data", "use_world_coords", "weld_vertices")
		def __repr__(self):
			return "%s(%s)"%(self.__class__.__name__, ",".join(tuple("%s=%r"%(a, getattr(self, a)()) for a in self.attrs)))
	%}
}

%extend IfcGeom::Iterator<float> {
	static int mantissa_size() {
		return std::numeric_limits<float>::digits;
	}
};

%extend IfcGeom::Iterator<double> {
	static int mantissa_size() {
		return std::numeric_limits<double>::digits;
	}
};

%extend IfcGeom::Representation::Triangulation {
	%pythoncode %{
		if _newclass:
			# Hide the getters with read-only property implementations
			id = property(id)
			faces = property(get_faces)
			edges = property(get_edges)
			material_ids = property(get_material_ids)
			materials = property(get_materials)
	%}
};

// Specialized accessors follow later, for otherwise property definitions
// would appear before templated getter functions are defined.
%extend IfcGeom::Representation::Triangulation<float> {
	%pythoncode %{
		if _newclass:
			# Hide the getters with read-only property implementations
			verts = property(get_verts)
			normals = property(get_normals)
	%}
};
%extend IfcGeom::Representation::Triangulation<double> {
	%pythoncode %{
		if _newclass:
			# Hide the getters with read-only property implementations
			verts = property(get_verts)
			normals = property(get_normals)
	%}
};

%extend IfcGeom::Representation::Serialization {
	%pythoncode %{
		if _newclass:
			# Hide the getters with read-only property implementations
			id = property(id)
			brep_data = property(brep_data)
	%}
};

%extend IfcGeom::Element {
	%pythoncode %{
		if _newclass:
			# Hide the getters with read-only property implementations
			id = property(id)
			parent_id = property(parent_id)
			name = property(name)
			type = property(type)
			guid = property(guid)
			context = property(context)
			unique_id = property(unique_id)
			transformation = property(transformation)
	%}
};

%extend IfcGeom::TriangulationElement {
	%pythoncode %{
		if _newclass:
			# Hide the getters with read-only property implementations
			geometry = property(geometry)
	%}
};

%extend IfcGeom::SerializedElement {
	%pythoncode %{
		if _newclass:
			# Hide the getters with read-only property implementations
			geometry = property(geometry)
	%}
};

%extend IfcGeom::Material {
	%pythoncode %{
		if _newclass:
			# Hide the getters with read-only property implementations
			has_diffuse = property(hasDiffuse)
			has_specular = property(hasSpecular)
			has_transparency = property(hasTransparency)
			has_specularity = property(hasSpecularity)
			diffuse = property(diffuse)
			specular = property(specular)
			transparency = property(transparency)
			specularity = property(specularity)
			name = property(name)
	%}
};

%extend IfcGeom::Transformation {
	%pythoncode %{
		if _newclass:
			# Hide the getters with read-only property implementations
			matrix = property(matrix)
	%}
};

%extend IfcGeom::Matrix {
	%pythoncode %{
		if _newclass:
			# Hide the getters with read-only property implementations
			data = property(data)
	%}
};

%inline %{
	boost::variant<IfcGeom::Element<double>*, IfcGeom::Representation::Representation*> create_shape(IfcGeom::IteratorSettings& settings, IfcParse::IfcLateBoundEntity* instance, IfcParse::IfcLateBoundEntity* representation = 0) {
		if (instance->is(IfcSchema::Type::IfcProduct)) {
			if (representation) {
				if (!representation->is(IfcSchema::Type::IfcRepresentation)) {
					throw IfcParse::IfcException("Supplied representation not of type IfcRepresentation");
				}
			}

			IfcParse::IfcFile* file = instance->entity->file;
			
			IfcSchema::IfcProject::list::ptr projects = file->entitiesByType<IfcSchema::IfcProject>();
			if (projects->size() != 1) {
				throw IfcParse::IfcException("Not a single IfcProject instance");
			}
			IfcSchema::IfcProject* project = *projects->begin();
			
			IfcGeom::Kernel kernel;
			kernel.setValue(IfcGeom::Kernel::GV_MAX_FACES_TO_SEW, settings.sew_shells() ? 1000 : -1);
			kernel.setValue(IfcGeom::Kernel::GV_DIMENSIONALITY, (settings.include_curves() ? (settings.exclude_solids_and_surfaces() ? -1. : 0.) : +1.));

			IfcSchema::IfcProduct* product = (IfcSchema::IfcProduct*) instance;

			if (!representation && !product->hasRepresentation()) {
				throw IfcParse::IfcException("Representation is NULL");
			}
			
			IfcSchema::IfcProductRepresentation* prodrep = product->Representation();
			IfcSchema::IfcRepresentation::list::ptr reps = prodrep->Representations();
			IfcSchema::IfcRepresentation* ifc_representation = (IfcSchema::IfcRepresentation*) representation;
			
			if (!ifc_representation) {
				// First, try to find a representation based on the settings
				for (IfcSchema::IfcRepresentation::list::it it = reps->begin(); it != reps->end(); ++it) {
					IfcSchema::IfcRepresentation* rep = *it;
					if (!settings.exclude_solids_and_surfaces()) {
						if (rep->RepresentationIdentifier() == "Body") {
							ifc_representation = rep;
							break;
						}
					}
					if (settings.include_curves()) {
						if (rep->RepresentationIdentifier() == "Plan" || rep->RepresentationIdentifier() == "Axis") {
							ifc_representation = rep;
							break;
						}
					}
				}
			}

			// Otherwise, find a representation within the 'Model' or 'Plan' context
			if (!ifc_representation) {
				for (IfcSchema::IfcRepresentation::list::it it = reps->begin(); it != reps->end(); ++it) {
					IfcSchema::IfcRepresentation* rep = *it;
					IfcSchema::IfcRepresentationContext* context = rep->ContextOfItems();
					
					// TODO: Remove redundancy with IfcGeomIterator.h
					if (context->hasContextType()) {
						std::set<std::string> context_types;
						if (!settings.exclude_solids_and_surfaces()) {
							context_types.insert("model");
							context_types.insert("design");
							context_types.insert("model view");
						}
						if (settings.include_curves()) {
							context_types.insert("plan");
						}			

						std::string context_type_lc = context->ContextType();
						for (std::string::iterator c = context_type_lc.begin(); c != context_type_lc.end(); ++c) {
							*c = tolower(*c);
						}
						if (context_types.find(context_type_lc) != context_types.end()) {
							ifc_representation = rep;
						}
					}
				}
			}

			if (!ifc_representation) {
				if (reps->size()) {
					// Return a random representation
					ifc_representation = *reps->begin();
				} else {
					throw IfcParse::IfcException("No suitable IfcRepresentation found");
				}
			}

			IfcSchema::IfcRepresentationContext* ctx = ifc_representation->ContextOfItems();
			if (!ctx->is(IfcSchema::Type::IfcGeometricRepresentationContext)) {
				throw IfcParse::IfcException("Context not of type IfcGeometricRepresentationContext");
			}
			IfcSchema::IfcGeometricRepresentationContext* context = (IfcSchema::IfcGeometricRepresentationContext*) ctx;
			if (context->is(IfcSchema::Type::IfcGeometricRepresentationSubContext)) {
				IfcSchema::IfcGeometricRepresentationSubContext* subcontext = (IfcSchema::IfcGeometricRepresentationSubContext*) context;
				context = subcontext->ParentContext();
			}

			double precision = 1.e-6;
			if (context->hasPrecision()) {
				precision = context->Precision();
			}
			std::pair<std::string, double> length_unit = kernel.initializeUnits(project->UnitsInContext());
			precision *= length_unit.second;

			// Some arbitrary factor that has proven to work better for the models in the set of test files.
			precision *= 10.;

			kernel.setValue(IfcGeom::Kernel::GV_PRECISION, precision);
			
			IfcGeom::BRepElement<double>* brep = kernel.create_brep_for_representation_and_product<double>(settings, ifc_representation, product);
			if (!brep) {
				throw IfcParse::IfcException("Failed to process shape");
			}
			if (settings.use_brep_data()) {
				IfcGeom::SerializedElement<double>* serialization = new IfcGeom::SerializedElement<double>(*brep);
				delete brep;
				return serialization;
			} else if (!settings.disable_triangulation()) {
				IfcGeom::TriangulationElement<double>* triangulation = new IfcGeom::TriangulationElement<double>(*brep);
				delete brep;
				return triangulation;
			} else {
				throw IfcParse::IfcException("No element to return based on provided settings");
			}
		} else {
			throw IfcParse::IfcException("Only obtaining representations for IfcProduct instances is currently supported");
		}
	}
%}

namespace IfcGeom {
	%template(iterator_single_precision) Iterator<float>;
	%template(iterator_double_precision) Iterator<double>;

	%template(element_single_precision) Element<float>;
	%template(element_double_precision) Element<double>;

	%template(triangulation_element_single_precision) TriangulationElement<float>;
	%template(triangulation_element_double_precision) TriangulationElement<double>;

	%template(serialized_element_single_precision) SerializedElement<float>;
	%template(serialized_element_double_precision) SerializedElement<double>;

	%template(transformation_single_precision) Transformation<float>;
	%template(transformation_double_precision) Transformation<double>;

	%template(matrix_single_precision) Matrix<float>;
	%template(matrix_double_precision) Matrix<double>;

	namespace Representation {
		%template(triangulation_single_precision) Triangulation<float>;
		%template(triangulation_double_precision) Triangulation<double>;
	};
};
